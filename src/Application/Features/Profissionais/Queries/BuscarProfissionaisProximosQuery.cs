using MediatR;
using AutoMapper;
using FreteAPI.Application.Common;
using FreteAPI.Application.Features.Profissionais.DTOs;
using FreteAPI.Domain.ValueObjects;
using FreteAPI.Domain.Interfaces;

namespace FreteAPI.Application.Features.Profissionais.Queries;

/// <summary>
/// Query para buscar profissionais próximos e disponíveis
/// </summary>
public record BuscarProfissionaisProximosQuery(BuscarProfissionaisProximosRequest Request) 
    : IRequest<Result<IEnumerable<ProfissionalProximoDto>>>;

/// <summary>
/// Handler para busca de profissionais próximos
/// </summary>
public class BuscarProfissionaisProximosQueryHandler 
    : IRequestHandler<BuscarProfissionaisProximosQuery, Result<IEnumerable<ProfissionalProximoDto>>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public BuscarProfissionaisProximosQueryHandler(IUnitOfWork unitOfWork, IMapper mapper)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
    }

    public async Task<Result<IEnumerable<ProfissionalProximoDto>>> Handle(
        BuscarProfissionaisProximosQuery request, 
        CancellationToken cancellationToken)
    {
        try
        {
            var req = request.Request;

            // Validações de negócio
            if (req.DataHora <= DateTime.Now.AddMinutes(30))
            {
                return Result<IEnumerable<ProfissionalProximoDto>>.FailureResult(
                    "Agendamento deve ser feito com pelo menos 30 minutos de antecedência");
            }

            var localizacaoCliente = new Localizacao(req.Latitude, req.Longitude);
            
            // Busca todos os profissionais ativos
            var profissionaisAtivos = await _unitOfWork.Profissionais.GetAtivosAsync(cancellationToken);

            var profissionaisDisponiveis = new List<ProfissionalProximoDto>();

            foreach (var profissional in profissionaisAtivos)
            {
                // Calcula distância
                var distancia = localizacaoCliente.DistanciaEmKmPara(profissional.Localizacao);
                
                // Verifica se está dentro do raio de atendimento
                if (distancia > profissional.RaioAtendimentoKm) continue;

                // Carrega profissional completo com disponibilidades e agendamentos
                var profissionalCompleto = await _unitOfWork.Profissionais
                    .GetComAgendamentosAsync(profissional.Id, cancellationToken);

                if (profissionalCompleto == null) continue;

                // Verifica disponibilidade no horário solicitado
                var duracao = TimeSpan.FromMinutes(req.DuracaoMinutos);
                if (!profissionalCompleto.EstaDisponivel(req.DataHora, duracao)) continue;

                var profissionalDto = _mapper.Map<ProfissionalProximoDto>(profissionalCompleto);
                profissionalDto.DistanciaKm = Math.Round(distancia, 2);
                
                profissionaisDisponiveis.Add(profissionalDto);
            }

            // Ordena por distância
            var resultado = profissionaisDisponiveis.OrderBy(p => p.DistanciaKm).ToList();

            return Result<IEnumerable<ProfissionalProximoDto>>.SuccessResult(resultado);
        }
        catch (ArgumentException ex)
        {
            return Result<IEnumerable<ProfissionalProximoDto>>.FailureResult(ex.Message);
        }
        catch (Exception ex)
        {
            return Result<IEnumerable<ProfissionalProximoDto>>.FailureResult($"Erro interno: {ex.Message}");
        }
    }
}