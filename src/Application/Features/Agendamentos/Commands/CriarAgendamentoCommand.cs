using MediatR;
using AutoMapper;
using FreteAPI.Application.Common;
using FreteAPI.Application.Features.Agendamentos.DTOs;
using FreteAPI.Domain.Entities;
using FreteAPI.Domain.Interfaces;

namespace FreteAPI.Application.Features.Agendamentos.Commands;

/// <summary>
/// Command para criar um novo agendamento
/// </summary>
public record CriarAgendamentoCommand(CriarAgendamentoRequest Request) : IRequest<Result<AgendamentoDto>>;

/// <summary>
/// Handler para criação de agendamento
/// </summary>
public class CriarAgendamentoCommandHandler : IRequestHandler<CriarAgendamentoCommand, Result<AgendamentoDto>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public CriarAgendamentoCommandHandler(IUnitOfWork unitOfWork, IMapper mapper)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
    }

    public async Task<Result<AgendamentoDto>> Handle(CriarAgendamentoCommand request, CancellationToken cancellationToken)
    {
        await _unitOfWork.BeginTransactionAsync(cancellationToken);
        
        try
        {
            var req = request.Request;

            // Validações de existência
            var cliente = await _unitOfWork.Clientes.GetByIdAsync(req.ClienteId, cancellationToken);
            if (cliente == null)
            {
                return Result<AgendamentoDto>.FailureResult("Cliente não encontrado");
            }

            var profissional = await _unitOfWork.Profissionais
                .GetComAgendamentosAsync(req.ProfissionalId, cancellationToken);
            
            if (profissional == null)
            {
                return Result<AgendamentoDto>.FailureResult("Profissional não encontrado");
            }

            if (!profissional.Ativo)
            {
                return Result<AgendamentoDto>.FailureResult("Profissional não está ativo");
            }

            // Validações de negócio
            var dataHoraInicio = req.Data.Date.Add(req.HoraInicio.ToTimeSpan());
            var duracao = req.HoraFim.ToTimeSpan() - req.HoraInicio.ToTimeSpan();

            if (dataHoraInicio <= DateTime.Now.AddMinutes(30))
            {
                return Result<AgendamentoDto>.FailureResult(
                    "Agendamento deve ser feito com pelo menos 30 minutos de antecedência");
            }

            // Verifica disponibilidade do profissional
            if (!profissional.EstaDisponivel(dataHoraInicio, duracao))
            {
                return Result<AgendamentoDto>.FailureResult(
                    "Profissional não está disponível no horário solicitado");
            }

            // Verifica conflitos de horário
            var temConflito = await _unitOfWork.Agendamentos.TemConflitoHorarioAsync(
                req.ProfissionalId, req.Data, req.HoraInicio, req.HoraFim, 
                cancellationToken: cancellationToken);

            if (temConflito)
            {
                return Result<AgendamentoDto>.FailureResult(
                    "Já existe um agendamento confirmado neste horário");
            }

            // Cria o agendamento
            var agendamento = new Agendamento(
                req.ClienteId,
                req.ProfissionalId,
                req.Data,
                req.HoraInicio,
                req.HoraFim,
                req.EnderecoOrigem,
                req.LatitudeOrigem,
                req.LongitudeOrigem);

            await _unitOfWork.Agendamentos.AddAsync(agendamento, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);
            
            // Busca o agendamento com todos os relacionamentos para retorno
            var agendamentoCompleto = await _unitOfWork.Agendamentos
                .GetComDetalhesAsync(agendamento.Id, cancellationToken);

            await _unitOfWork.CommitTransactionAsync(cancellationToken);

            var agendamentoDto = _mapper.Map<AgendamentoDto>(agendamentoCompleto);
            return Result<AgendamentoDto>.SuccessResult(agendamentoDto);
        }
        catch (ArgumentException ex)
        {
            await _unitOfWork.RollbackTransactionAsync(cancellationToken);
            return Result<AgendamentoDto>.FailureResult(ex.Message);
        }
        catch (Exception ex)
        {
            await _unitOfWork.RollbackTransactionAsync(cancellationToken);
            return Result<AgendamentoDto>.FailureResult($"Erro interno: {ex.Message}");
        }
    }
}