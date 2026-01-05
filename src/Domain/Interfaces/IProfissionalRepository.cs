using FreteAPI.Domain.Entities;
using FreteAPI.Domain.ValueObjects;

namespace FreteAPI.Domain.Interfaces;

/// <summary>
/// Interface para repositório de profissionais
/// </summary>
public interface IProfissionalRepository : IRepository<Profissional>
{
    Task<Profissional?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<Profissional?> GetByTelefoneAsync(string telefone, CancellationToken cancellationToken = default);
    Task<IEnumerable<Profissional>> GetAtivosAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<Profissional>> GetPorProximidadeAsync(Localizacao localizacao, double raioMaximoKm, CancellationToken cancellationToken = default);
    Task<Profissional?> GetComDisponibilidadesAsync(Guid id, CancellationToken cancellationToken = default);
    Task<Profissional?> GetComAgendamentosAsync(Guid id, CancellationToken cancellationToken = default);
}