using Microsoft.AspNetCore.Mvc;
using MediatR;
using FreteAPI.Application.Common;
using FreteAPI.Application.Features.Profissionais.DTOs;
using FreteAPI.Application.Features.Profissionais.Queries;

namespace FreteAPI.Api.Controllers;

/// <summary>
/// Controller para operações relacionadas a profissionais
/// </summary>
[ApiController]
[Asp.Versioning.ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
[Produces("application/json")]
public class ProfissionaisController : ControllerBase
{
    private readonly IMediator _mediator;

    public ProfissionaisController(IMediator mediator)
    {
        _mediator = mediator;
    }

    /// <summary>
    /// Busca profissionais próximos e disponíveis
    /// </summary>
    /// <param name="request">Parâmetros de busca</param>
    /// <param name="cancellationToken">Token de cancelamento</param>
    /// <returns>Lista de profissionais próximos ordenada por distância</returns>
    /// <response code="200">Busca realizada com sucesso</response>
    /// <response code="400">Parâmetros inválidos</response>
    /// <response code="500">Erro interno do servidor</response>
    [HttpGet("proximos")]
    [ProducesResponseType(typeof(IEnumerable<ProfissionalProximoDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> BuscarProfissionaisProximos(
        [FromQuery] BuscarProfissionaisProximosRequest request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var query = new BuscarProfissionaisProximosQuery(request);
        var result = await _mediator.Send(query, cancellationToken);

        if (!result.Success)
        {
            var problemDetails = new ProblemDetails
            {
                Title = "Erro ao buscar profissionais",
                Status = StatusCodes.Status400BadRequest,
                Detail = string.Join("; ", result.Errors)
            };

            return BadRequest(problemDetails);
        }

        return Ok(result.Data);
    }

    /// <summary>
    /// Cria um novo profissional (placeholder)
    /// </summary>
    /// <param name="request">Dados do profissional</param>
    /// <param name="cancellationToken">Token de cancelamento</param>
    /// <returns>Profissional criado</returns>
    [HttpPost]
    [ApiExplorerSettings(IgnoreApi = true)] // Implementar depois
    public IActionResult CriarProfissional(
        [FromBody] CriarProfissionalRequest request,
        CancellationToken cancellationToken)
    {
        // Implementar comando CriarProfissional
        return StatusCode(501, "Não implementado ainda");
    }

    /// <summary>
    /// Adiciona disponibilidade para um profissional (placeholder)
    /// </summary>
    /// <param name="id">ID do profissional</param>
    /// <param name="request">Dados da disponibilidade</param>
    /// <param name="cancellationToken">Token de cancelamento</param>
    /// <returns>Disponibilidade criada</returns>
    [HttpPost("{id:guid}/disponibilidade")]
    [ApiExplorerSettings(IgnoreApi = true)] // Implementar depois
    public IActionResult AdicionarDisponibilidade(
        Guid id,
        [FromBody] AdicionarDisponibilidadeRequest request,
        CancellationToken cancellationToken)
    {
        // Implementar comando AdicionarDisponibilidade
        return StatusCode(501, "Não implementado ainda");
    }
}