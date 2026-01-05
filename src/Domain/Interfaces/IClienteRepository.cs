using FreteAPI.Domain.Entities;

namespace FreteAPI.Domain.Interfaces;

/// <summary>
/// Interface para repositório de clientes
/// </summary>
public interface IClienteRepository : IRepository<Cliente>
{
    Task<Cliente?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<Cliente?> GetByTelefoneAsync(string telefone, CancellationToken cancellationToken = default);
}