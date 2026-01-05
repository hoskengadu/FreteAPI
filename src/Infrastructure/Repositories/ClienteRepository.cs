using Microsoft.EntityFrameworkCore;
using FreteAPI.Domain.Entities;
using FreteAPI.Domain.Interfaces;
using FreteAPI.Infrastructure.Data;

namespace FreteAPI.Infrastructure.Repositories;

/// <summary>
/// Implementação do repositório de clientes
/// </summary>
public class ClienteRepository : Repository<Cliente>, IClienteRepository
{
    public ClienteRepository(FreteDbContext context) : base(context) { }

    public async Task<Cliente?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .FirstOrDefaultAsync(c => c.Email == email.ToLower(), cancellationToken);
    }

    public async Task<Cliente?> GetByTelefoneAsync(string telefone, CancellationToken cancellationToken = default)
    {
        // Remove caracteres não numéricos para comparação
        var telefoneNumerico = new string(telefone.Where(char.IsDigit).ToArray());
        
        return await _dbSet
            .FirstOrDefaultAsync(c => c.Telefone == telefoneNumerico, cancellationToken);
    }
}