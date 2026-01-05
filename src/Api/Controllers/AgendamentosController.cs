using Microsoft.AspNetCore.Mvc;
using MediatR;
using FreteAPI.Application.Common;
using FreteAPI.Application.Features.Agendamentos.DTOs;
using FreteAPI.Application.Features.Agendamentos.Commands;

namespace FreteAPI.Api.Controllers;

/// <summary>
/// Controller para operações relacionadas a agendamentos
/// </summary>
[ApiController]
[Asp.Versioning.ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
[Produces("application/json")]
public class AgendamentosController : ControllerBase
{
    private readonly IMediator _mediator;

    public AgendamentosController(IMediator mediator)
    {
        _mediator = mediator;
    }

    /// <summary>
    /// Cria um novo agendamento
    /// </summary>
    /// <param name="request">Dados do agendamento a ser criado</param>
    /// <param name="cancellationToken">Token de cancelamento</param>
    /// <returns>Agendamento criado</returns>
    /// <response code="201">Agendamento criado com sucesso</response>
    /// <response code="400">Dados inválidos ou conflito de horário</response>
    /// <response code="404">Cliente ou profissional não encontrado</response>
    /// <response code="500">Erro interno do servidor</response>
    [HttpPost]
    [ProducesResponseType(typeof(AgendamentoDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> CriarAgendamento(
        [FromBody] CriarAgendamentoRequest request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var command = new CriarAgendamentoCommand(request);
        var result = await _mediator.Send(command, cancellationToken);

        if (!result.Success)
        {
            var statusCode = StatusCodes.Status400BadRequest;
            
            // Determina o status code baseado no erro
            if (result.Errors.Any(e => e.Contains("não encontrado")))
            {
                statusCode = StatusCodes.Status404NotFound;
            }

            var problemDetails = new ProblemDetails
            {
                Title = "Erro ao criar agendamento",
                Status = statusCode,
                Detail = string.Join("; ", result.Errors)
            };

            return StatusCode(statusCode, problemDetails);
        }

        return CreatedAtAction(
            nameof(ObterAgendamentoPorId),
            new { id = result.Data!.Id },
            result.Data);
    }

    /// <summary>
    /// Obtém um agendamento por ID (placeholder para rota)
    /// </summary>
    /// <param name="id">ID do agendamento</param>
    /// <returns>Agendamento encontrado</returns>
    [HttpGet("{id:guid}")]
    [ApiExplorerSettings(IgnoreApi = true)] // Temporário - implementar depois
    public IActionResult ObterAgendamentoPorId(Guid id)
    {
        // Implementar depois - aqui apenas para ter a rota para CreatedAtAction
        return NotFound();
    }

    /// <summary>
    /// Cancela um agendamento (placeholder)
    /// </summary>
    /// <param name="id">ID do agendamento</param>
    /// <param name="cancellationToken">Token de cancelamento</param>
    /// <returns>Resultado da operação</returns>
    [HttpDelete("{id:guid}")]
    [ApiExplorerSettings(IgnoreApi = true)] // Implementar depois
    public IActionResult CancelarAgendamento(Guid id, CancellationToken cancellationToken)
    {
        // Implementar comando CancelarAgendamento
        return StatusCode(501, "Não implementado ainda");
    }
}