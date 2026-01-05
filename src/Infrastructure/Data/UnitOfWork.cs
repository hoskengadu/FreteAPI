using FreteAPI.Domain.Interfaces;
using FreteAPI.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore.Storage;

namespace FreteAPI.Infrastructure.Data
{
    /// <summary>
    /// Implementação do Unit of Work
    /// </summary>
    public class UnitOfWork : IUnitOfWork
{
    private readonly FreteDbContext _context;
    private IDbContextTransaction? _transaction;
    
    private IClienteRepository? _clientes;
    private IProfissionalRepository? _profissionais;
    private IDisponibilidadeRepository? _disponibilidades;
    private IAgendamentoRepository? _agendamentos;

    public UnitOfWork(FreteDbContext context)
    {
        _context = context;
    }

    public IClienteRepository Clientes =>
        _clientes ??= new ClienteRepository(_context);

    public IProfissionalRepository Profissionais =>
        _profissionais ??= new ProfissionalRepository(_context);

    public IDisponibilidadeRepository Disponibilidades =>
        _disponibilidades ??= new DisponibilidadeRepository(_context);

    public IAgendamentoRepository Agendamentos =>
        _agendamentos ??= new AgendamentoRepository(_context);

    public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task BeginTransactionAsync(CancellationToken cancellationToken = default)
    {
        _transaction = await _context.Database.BeginTransactionAsync(cancellationToken);
    }

    public async Task CommitTransactionAsync(CancellationToken cancellationToken = default)
    {
        if (_transaction != null)
        {
            await _transaction.CommitAsync(cancellationToken);
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }

    public async Task RollbackTransactionAsync(CancellationToken cancellationToken = default)
    {
        if (_transaction != null)
        {
            await _transaction.RollbackAsync(cancellationToken);
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }

    public void Dispose()
    {
        _transaction?.Dispose();
        _context.Dispose();
    }
}
}