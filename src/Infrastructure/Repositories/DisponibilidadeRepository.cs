using FreteAPI.Domain.Entities;
using FreteAPI.Domain.Interfaces;
using FreteAPI.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FreteAPI.Infrastructure.Repositories;

/// <summary>
/// Implementação do repositório de Disponibilidade
/// </summary>
public class DisponibilidadeRepository : Repository<Disponibilidade>, IDisponibilidadeRepository
{
    public DisponibilidadeRepository(FreteDbContext context) : base(context)
    {
    }

    public async Task<IEnumerable<Disponibilidade>> ObterDisponibilidadesPorProfissionalAsync(Guid profissionalId, CancellationToken cancellationToken = default)
    {
        return await _context.Disponibilidades
            .Where(d => d.ProfissionalId == profissionalId)
            .Include(d => d.Profissional)
            .OrderBy(d => d.DiaSemana)
            .ThenBy(d => d.HoraInicio)
            .ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<Disponibilidade>> ObterDisponibilidadesPorDataAsync(DateTime data, CancellationToken cancellationToken = default)
    {
        var diaSemana = data.DayOfWeek;

        return await _context.Disponibilidades
            .Where(d => d.DiaSemana == diaSemana)
            .Include(d => d.Profissional)
            .OrderBy(d => d.HoraInicio)
            .ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<Disponibilidade>> ObterDisponibilidadesLivresAsync(DateTime dataInicio, DateTime dataFim, CancellationToken cancellationToken = default)
    {
        var diaSemana = dataInicio.DayOfWeek;
        
        return await _context.Disponibilidades
            .Where(d => d.DiaSemana == diaSemana)
            .Include(d => d.Profissional)
            .OrderBy(d => d.HoraInicio)
            .ToListAsync(cancellationToken);
    }

    public async Task<bool> VerificarConflitosAsync(Guid profissionalId, DateTime dataInicio, DateTime dataFim, Guid? disponibilidadeId = null, CancellationToken cancellationToken = default)
    {
        var diaSemana = dataInicio.DayOfWeek;
        var horaInicio = TimeOnly.FromDateTime(dataInicio);
        var horaFim = TimeOnly.FromDateTime(dataFim);

        var query = _context.Disponibilidades
            .Where(d => d.ProfissionalId == profissionalId &&
                       d.DiaSemana == diaSemana &&
                       d.HoraInicio < horaFim && d.HoraFim > horaInicio);

        if (disponibilidadeId.HasValue)
        {
            query = query.Where(d => d.Id != disponibilidadeId.Value);
        }

        return await query.AnyAsync(cancellationToken);
    }
}