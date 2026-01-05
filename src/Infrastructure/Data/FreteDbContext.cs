using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using FreteAPI.Domain.Entities;
using FreteAPI.Domain.ValueObjects;
using FreteAPI.Domain.Enums;

namespace FreteAPI.Infrastructure.Data;

/// <summary>
/// Contexto do Entity Framework para a aplicação
/// </summary>
public class FreteDbContext : DbContext
{
    private IDbContextTransaction? _currentTransaction;

    public FreteDbContext(DbContextOptions<FreteDbContext> options) : base(options) { }

    public DbSet<Cliente> Clientes { get; set; }
    public DbSet<Profissional> Profissionais { get; set; }
    public DbSet<Disponibilidade> Disponibilidades { get; set; }
    public DbSet<Agendamento> Agendamentos { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configurações para Cliente
        modelBuilder.Entity<Cliente>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).ValueGeneratedNever();
            
            entity.Property(e => e.Nome)
                .HasMaxLength(100)
                .IsRequired();

            entity.Property(e => e.Email)
                .HasMaxLength(255)
                .IsRequired();

            entity.Property(e => e.Telefone)
                .HasMaxLength(11)
                .IsRequired();

            entity.Property(e => e.DataCriacao)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            // Configuração para Value Object Localizacao
            entity.OwnsOne(e => e.Localizacao, loc =>
            {
                loc.Property(l => l.Latitude)
                    .HasColumnName("Latitude")
                    .HasPrecision(10, 7)
                    .IsRequired();

                loc.Property(l => l.Longitude)
                    .HasColumnName("Longitude")
                    .HasPrecision(10, 7)
                    .IsRequired();
            });

            // Índices
            entity.HasIndex(e => e.Email).IsUnique();
            entity.HasIndex(e => e.Telefone).IsUnique();
        });

        // Configurações para Profissional
        modelBuilder.Entity<Profissional>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).ValueGeneratedNever();
            
            entity.Property(e => e.Nome)
                .HasMaxLength(100)
                .IsRequired();

            entity.Property(e => e.Email)
                .HasMaxLength(255)
                .IsRequired();

            entity.Property(e => e.Telefone)
                .HasMaxLength(11)
                .IsRequired();

            entity.Property(e => e.RaioAtendimentoKm)
                .HasPrecision(5, 2)
                .IsRequired();

            entity.Property(e => e.Ativo)
                .HasDefaultValue(true);

            entity.Property(e => e.DataCriacao)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            // Configuração para Value Object Localizacao
            entity.OwnsOne(e => e.Localizacao, loc =>
            {
                loc.Property(l => l.Latitude)
                    .HasColumnName("Latitude")
                    .HasPrecision(10, 7)
                    .IsRequired();

                loc.Property(l => l.Longitude)
                    .HasColumnName("Longitude")
                    .HasPrecision(10, 7)
                    .IsRequired();
            });

            // Relacionamentos
            entity.HasMany(e => e.Disponibilidades)
                .WithOne(d => d.Profissional)
                .HasForeignKey(d => d.ProfissionalId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasMany(e => e.Agendamentos)
                .WithOne(a => a.Profissional)
                .HasForeignKey(a => a.ProfissionalId)
                .OnDelete(DeleteBehavior.Restrict);

            // Índices
            entity.HasIndex(e => e.Email).IsUnique();
            entity.HasIndex(e => e.Telefone).IsUnique();
            entity.HasIndex(e => e.Ativo);
            entity.HasIndex(e => new { e.Ativo, Latitude = e.Localizacao.Latitude, Longitude = e.Localizacao.Longitude });
        });

        // Configurações para Disponibilidade
        modelBuilder.Entity<Disponibilidade>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).ValueGeneratedNever();

            entity.Property(e => e.DiaSemana)
                .HasConversion<int>()
                .IsRequired();

            entity.Property(e => e.HoraInicio)
                .IsRequired();

            entity.Property(e => e.HoraFim)
                .IsRequired();

            entity.Property(e => e.DataCriacao)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            // Relacionamento
            entity.HasOne(e => e.Profissional)
                .WithMany(p => p.Disponibilidades)
                .HasForeignKey(e => e.ProfissionalId)
                .OnDelete(DeleteBehavior.Cascade);

            // Índices
            entity.HasIndex(e => new { e.ProfissionalId, e.DiaSemana }).IsUnique();
        });

        // Configurações para Agendamento
        modelBuilder.Entity<Agendamento>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).ValueGeneratedNever();

            entity.Property(e => e.Data)
                .HasColumnType("date")
                .IsRequired();

            entity.Property(e => e.HoraInicio)
                .IsRequired();

            entity.Property(e => e.HoraFim)
                .IsRequired();

            entity.Property(e => e.Status)
                .HasConversion<int>()
                .IsRequired();

            entity.Property(e => e.EnderecoOrigem)
                .HasMaxLength(200)
                .IsRequired();

            entity.Property(e => e.DataCriacao)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");

            // Configuração para Value Object Localizacao
            entity.OwnsOne(e => e.LocalizacaoOrigem, loc =>
            {
                loc.Property(l => l.Latitude)
                    .HasColumnName("LatitudeOrigem")
                    .HasPrecision(10, 7)
                    .IsRequired();

                loc.Property(l => l.Longitude)
                    .HasColumnName("LongitudeOrigem")
                    .HasPrecision(10, 7)
                    .IsRequired();
            });

            // Relacionamentos
            entity.HasOne(e => e.Cliente)
                .WithMany()
                .HasForeignKey(e => e.ClienteId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.Profissional)
                .WithMany(p => p.Agendamentos)
                .HasForeignKey(e => e.ProfissionalId)
                .OnDelete(DeleteBehavior.Restrict);

            // Índices
            entity.HasIndex(e => e.ClienteId);
            entity.HasIndex(e => e.ProfissionalId);
            entity.HasIndex(e => new { e.Data, e.Status });
            entity.HasIndex(e => new { e.ProfissionalId, e.Data, e.HoraInicio, e.HoraFim });
        });
    }

    public async Task<IDbContextTransaction> BeginTransactionAsync()
    {
        if (_currentTransaction != null)
        {
            return _currentTransaction;
        }

        _currentTransaction = await Database.BeginTransactionAsync();
        return _currentTransaction;
    }

    public async Task CommitTransactionAsync()
    {
        try
        {
            await SaveChangesAsync();
            await (_currentTransaction?.CommitAsync() ?? Task.CompletedTask);
        }
        catch
        {
            await RollbackTransactionAsync();
            throw;
        }
        finally
        {
            if (_currentTransaction != null)
            {
                _currentTransaction.Dispose();
                _currentTransaction = null;
            }
        }
    }

    public async Task RollbackTransactionAsync()
    {
        try
        {
            await (_currentTransaction?.RollbackAsync() ?? Task.CompletedTask);
        }
        finally
        {
            if (_currentTransaction != null)
            {
                _currentTransaction.Dispose();
                _currentTransaction = null;
            }
        }
    }
}