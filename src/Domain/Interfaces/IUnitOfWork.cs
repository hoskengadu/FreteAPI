namespace FreteAPI.Domain.Interfaces;

/// <summary>
/// Interface para Unit of Work
/// </summary>
public interface IUnitOfWork : IDisposable
{
    IClienteRepository Clientes { get; }
    IProfissionalRepository Profissionais { get; }
    IDisponibilidadeRepository Disponibilidades { get; }
    IAgendamentoRepository Agendamentos { get; }
    
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
    Task BeginTransactionAsync(CancellationToken cancellationToken = default);
    Task CommitTransactionAsync(CancellationToken cancellationToken = default);
    Task RollbackTransactionAsync(CancellationToken cancellationToken = default);
}