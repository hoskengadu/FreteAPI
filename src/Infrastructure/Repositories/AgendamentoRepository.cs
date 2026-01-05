using Microsoft.EntityFrameworkCore;
using FreteAPI.Domain.Entities;
using FreteAPI.Domain.Interfaces;
using FreteAPI.Domain.Enums;
using FreteAPI.Infrastructure.Data;

namespace FreteAPI.Infrastructure.Repositories;

/// <summary>
/// Implementação do repositório de agendamentos
/// </summary>
public class AgendamentoRepository : Repository<Agendamento>, IAgendamentoRepository
{
    public AgendamentoRepository(FreteDbContext context) : base(context) { }

    public async Task<IEnumerable<Agendamento>> GetPorClienteAsync(Guid clienteId, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(a => a.ClienteId == clienteId)
            .OrderByDescending(a => a.Data)
            .ThenByDescending(a => a.HoraInicio)
            .ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<Agendamento>> GetPorProfissionalAsync(Guid profissionalId, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(a => a.ProfissionalId == profissionalId)
            .OrderByDescending(a => a.Data)
            .ThenByDescending(a => a.HoraInicio)
            .ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<Agendamento>> GetPorDataAsync(DateTime data, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(a => a.Data.Date == data.Date)
            .OrderBy(a => a.HoraInicio)
            .ToListAsync(cancellationToken);
    }

    public async Task<Agendamento?> GetComDetalhesAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(a => a.Cliente)
            .Include(a => a.Profissional)
                .ThenInclude(p => p.Disponibilidades)
            .FirstOrDefaultAsync(a => a.Id == id, cancellationToken);
    }

    public async Task<bool> TemConflitoHorarioAsync(Guid profissionalId, DateTime data, TimeOnly horaInicio, 
        TimeOnly horaFim, Guid? agendamentoId = null, CancellationToken cancellationToken = default)
    {
        var query = _dbSet
            .Where(a => a.ProfissionalId == profissionalId 
                       && a.Data.Date == data.Date 
                       && a.Status != StatusAgendamento.Cancelado);

        if (agendamentoId.HasValue)
        {
            query = query.Where(a => a.Id != agendamentoId.Value);
        }

        return await query
            .AnyAsync(a => !(horaFim <= a.HoraInicio || horaInicio >= a.HoraFim), cancellationToken);
    }
}