using FreteAPI.Domain.Entities;

namespace FreteAPI.Domain.Interfaces;

/// <summary>
/// Interface para repositório de Disponibilidade
/// </summary>
public interface IDisponibilidadeRepository : IRepository<Disponibilidade>
{
    Task<IEnumerable<Disponibilidade>> ObterDisponibilidadesPorProfissionalAsync(Guid profissionalId, CancellationToken cancellationToken = default);
    Task<IEnumerable<Disponibilidade>> ObterDisponibilidadesPorDataAsync(DateTime data, CancellationToken cancellationToken = default);
    Task<IEnumerable<Disponibilidade>> ObterDisponibilidadesLivresAsync(DateTime dataInicio, DateTime dataFim, CancellationToken cancellationToken = default);
    Task<bool> VerificarConflitosAsync(Guid profissionalId, DateTime dataInicio, DateTime dataFim, Guid? disponibilidadeId = null, CancellationToken cancellationToken = default);
}