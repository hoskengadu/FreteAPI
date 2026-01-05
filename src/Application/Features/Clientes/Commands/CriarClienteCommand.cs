using MediatR;
using AutoMapper;
using FreteAPI.Application.Common;
using FreteAPI.Application.Features.Clientes.DTOs;
using FreteAPI.Domain.Entities;
using FreteAPI.Domain.Interfaces;

namespace FreteAPI.Application.Features.Clientes.Commands;

/// <summary>
/// Command para criar um novo cliente
/// </summary>
public record CriarClienteCommand(CriarClienteRequest Request) : IRequest<Result<ClienteDto>>;

/// <summary>
/// Handler para criação de cliente
/// </summary>
public class CriarClienteCommandHandler : IRequestHandler<CriarClienteCommand, Result<ClienteDto>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public CriarClienteCommandHandler(IUnitOfWork unitOfWork, IMapper mapper)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
    }

    public async Task<Result<ClienteDto>> Handle(CriarClienteCommand request, CancellationToken cancellationToken)
    {
        try
        {
            var req = request.Request;

            // Verifica se já existe cliente com o email
            var clienteExistente = await _unitOfWork.Clientes.GetByEmailAsync(req.Email, cancellationToken);
            if (clienteExistente != null)
            {
                return Result<ClienteDto>.FailureResult("Já existe um cliente com este email");
            }

            // Verifica se já existe cliente com o telefone
            var telefoneExistente = await _unitOfWork.Clientes.GetByTelefoneAsync(req.Telefone, cancellationToken);
            if (telefoneExistente != null)
            {
                return Result<ClienteDto>.FailureResult("Já existe um cliente com este telefone");
            }

            // Cria o cliente
            var cliente = new Cliente(req.Nome, req.Email, req.Telefone, req.Latitude, req.Longitude);

            await _unitOfWork.Clientes.AddAsync(cliente, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);

            var clienteDto = _mapper.Map<ClienteDto>(cliente);
            return Result<ClienteDto>.SuccessResult(clienteDto);
        }
        catch (ArgumentException ex)
        {
            return Result<ClienteDto>.FailureResult(ex.Message);
        }
        catch (Exception ex)
        {
            return Result<ClienteDto>.FailureResult($"Erro interno: {ex.Message}");
        }
    }
}