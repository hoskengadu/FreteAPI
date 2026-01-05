using Microsoft.EntityFrameworkCore;
using FreteAPI.Domain.Entities;
using FreteAPI.Domain.Interfaces;
using FreteAPI.Domain.ValueObjects;
using FreteAPI.Infrastructure.Data;

namespace FreteAPI.Infrastructure.Repositories;

/// <summary>
/// Implementação do repositório de profissionais
/// </summary>
public class ProfissionalRepository : Repository<Profissional>, IProfissionalRepository
{
    public ProfissionalRepository(FreteDbContext context) : base(context) { }

    public async Task<Profissional?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .FirstOrDefaultAsync(p => p.Email == email.ToLower(), cancellationToken);
    }

    public async Task<Profissional?> GetByTelefoneAsync(string telefone, CancellationToken cancellationToken = default)
    {
        var telefoneNumerico = new string(telefone.Where(char.IsDigit).ToArray());
        
        return await _dbSet
            .FirstOrDefaultAsync(p => p.Telefone == telefoneNumerico, cancellationToken);
    }

    public async Task<IEnumerable<Profissional>> GetAtivosAsync(CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(p => p.Ativo)
            .ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<Profissional>> GetPorProximidadeAsync(Localizacao localizacao, double raioMaximoKm, CancellationToken cancellationToken = default)
    {
        // Implementação simplificada - em produção, usaria função SQL específica para cálculo de distância
        var profissionais = await _dbSet
            .Where(p => p.Ativo)
            .ToListAsync(cancellationToken);

        return profissionais.Where(p => 
            localizacao.DistanciaEmKmPara(p.Localizacao) <= raioMaximoKm &&
            localizacao.DistanciaEmKmPara(p.Localizacao) <= p.RaioAtendimentoKm);
    }

    public async Task<Profissional?> GetComDisponibilidadesAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(p => p.Disponibilidades)
            .FirstOrDefaultAsync(p => p.Id == id, cancellationToken);
    }

    public async Task<Profissional?> GetComAgendamentosAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(p => p.Disponibilidades)
            .Include(p => p.Agendamentos.Where(a => a.Status != Domain.Enums.StatusAgendamento.Cancelado))
            .FirstOrDefaultAsync(p => p.Id == id, cancellationToken);
    }
}