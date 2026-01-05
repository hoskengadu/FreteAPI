using FreteAPI.Domain.Entities;

namespace FreteAPI.Domain.Interfaces;

/// <summary>
/// Interface para repositório de agendamentos
/// </summary>
public interface IAgendamentoRepository : IRepository<Agendamento>
{
    Task<IEnumerable<Agendamento>> GetPorClienteAsync(Guid clienteId, CancellationToken cancellationToken = default);
    Task<IEnumerable<Agendamento>> GetPorProfissionalAsync(Guid profissionalId, CancellationToken cancellationToken = default);
    Task<IEnumerable<Agendamento>> GetPorDataAsync(DateTime data, CancellationToken cancellationToken = default);
    Task<Agendamento?> GetComDetalhesAsync(Guid id, CancellationToken cancellationToken = default);
    Task<bool> TemConflitoHorarioAsync(Guid profissionalId, DateTime data, TimeOnly horaInicio, TimeOnly horaFim, Guid? agendamentoId = null, CancellationToken cancellationToken = default);
}