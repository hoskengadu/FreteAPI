using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Mvc.ApiExplorer;
using Microsoft.OpenApi.Models;
using Serilog;
using System.Reflection;
using AspNetCoreRateLimit;
using FreteAPI.Infrastructure.Data;
using FreteAPI.Domain.Interfaces;
using FreteAPI.Infrastructure.Repositories;
using FreteAPI.Application.Common;

var builder = WebApplication.CreateBuilder(args);

// Configuração do Serilog
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .WriteTo.File("logs/FreteAPI-.txt", rollingInterval: RollingInterval.Day)
    .CreateLogger();

builder.Host.UseSerilog();

// Add services to the container.
builder.Services.AddControllers();

// Entity Framework
builder.Services.AddDbContext<FreteDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Repository Pattern & Unit of Work
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<IClienteRepository, ClienteRepository>();
builder.Services.AddScoped<IProfissionalRepository, ProfissionalRepository>();
builder.Services.AddScoped<IDisponibilidadeRepository, DisponibilidadeRepository>();
builder.Services.AddScoped<IAgendamentoRepository, AgendamentoRepository>();

// MediatR
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(
    typeof(MappingProfile).Assembly));

// AutoMapper
builder.Services.AddAutoMapper(typeof(MappingProfile));

// API Versioning
builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new Asp.Versioning.ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
})
.AddApiExplorer(setup =>
{
    setup.GroupNameFormat = "'v'VVV";
    setup.SubstituteApiVersionInUrl = true;
});

// Rate Limiting
builder.Services.AddMemoryCache();
builder.Services.Configure<IpRateLimitOptions>(builder.Configuration.GetSection("IpRateLimiting"));
builder.Services.AddSingleton<IIpPolicyStore, MemoryCacheIpPolicyStore>();
builder.Services.AddSingleton<IRateLimitCounterStore, MemoryCacheRateLimitCounterStore>();
builder.Services.AddSingleton<IRateLimitConfiguration, RateLimitConfiguration>();
builder.Services.AddSingleton<IProcessingStrategy, AsyncKeyLockProcessingStrategy>();

// Health Checks
builder.Services.AddHealthChecks()
    .AddNpgSql(builder.Configuration.GetConnectionString("DefaultConnection")!);

// Swagger/OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Frete API",
        Version = "v1",
        Description = "API RESTful para sistema de agendamento de fretes",
        Contact = new OpenApiContact
        {
            Name = "Equipe de Desenvolvimento",
            Email = "dev@freteapi.com"
        }
    });

    // Include XML comments
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
    {
        c.IncludeXmlComments(xmlPath);
    }

    // JWT Configuration (para quando implementar)
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme (Example: 'Bearer 12345abcdef')",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// CORS
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        var apiVersionDescriptionProvider = app.Services.GetRequiredService<IApiVersionDescriptionProvider>();
        foreach (var description in apiVersionDescriptionProvider.ApiVersionDescriptions)
        {
            c.SwaggerEndpoint($"/swagger/{description.GroupName}/swagger.json",
                $"Frete API {description.GroupName.ToUpperInvariant()}");
        }
        
        c.RoutePrefix = string.Empty; // Swagger na raiz
    });
}

// Middleware pipeline
app.UseSerilogRequestLogging();

app.UseHttpsRedirection();

app.UseCors();

app.UseIpRateLimiting();

app.UseAuthorization();

app.MapControllers();

// Health Check endpoint
app.MapHealthChecks("/health");

// Seed inicial dos dados
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<FreteDbContext>();
    
    try
    {
        await context.Database.MigrateAsync();
        Log.Information("Database migration completed successfully");
        
        // Seed inicial (se necessário)
        await SeedData(context);
    }
    catch (Exception ex)
    {
        Log.Fatal(ex, "An error occurred while migrating the database");
        throw;
    }
}

Log.Information("Starting Frete API");
app.Run();

// Método para seed inicial dos dados
static async Task SeedData(FreteDbContext context)
{
    // Verifica se já existem dados
    if (await context.Clientes.AnyAsync() || await context.Profissionais.AnyAsync())
    {
        Log.Information("Database already has data, skipping seed");
        return;
    }

    Log.Information("Seeding initial data");

    // Seed de clientes exemplo
    var clientes = new[]
    {
        new FreteAPI.Domain.Entities.Cliente("João Silva", "joao@email.com", "11999999001", -23.5505, -46.6333),
        new FreteAPI.Domain.Entities.Cliente("Maria Santos", "maria@email.com", "11999999002", -23.5489, -46.6388),
    };

    // Seed de profissionais exemplo  
    var profissionais = new[]
    {
        new FreteAPI.Domain.Entities.Profissional("Carlos Freteiro", "carlos@email.com", "11888888001", -23.5400, -46.6200, 15.0),
        new FreteAPI.Domain.Entities.Profissional("Ana Transportes", "ana@email.com", "11888888002", -23.5600, -46.6500, 20.0),
    };

    await context.Clientes.AddRangeAsync(clientes);
    await context.Profissionais.AddRangeAsync(profissionais);
    await context.SaveChangesAsync();

    // Adiciona disponibilidades exemplo
    foreach (var prof in profissionais)
    {
        for (var dia = DayOfWeek.Monday; dia <= DayOfWeek.Friday; dia++)
        {
            prof.AdicionarDisponibilidade(dia, new TimeOnly(8, 0), new TimeOnly(18, 0));
        }
    }

    await context.SaveChangesAsync();
    Log.Information("Initial data seeded successfully");
}