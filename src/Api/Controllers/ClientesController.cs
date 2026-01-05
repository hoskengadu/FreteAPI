using Microsoft.AspNetCore.Mvc;
using MediatR;
using FreteAPI.Application.Common;
using FreteAPI.Application.Features.Clientes.DTOs;
using FreteAPI.Application.Features.Clientes.Commands;

namespace FreteAPI.Api.Controllers;

/// <summary>
/// Controller para operações relacionadas a clientes
/// </summary>
[ApiController]
[Asp.Versioning.ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
[Produces("application/json")]
public class ClientesController : ControllerBase
{
    private readonly IMediator _mediator;

    public ClientesController(IMediator mediator)
    {
        _mediator = mediator;
    }

    /// <summary>
    /// Cria um novo cliente
    /// </summary>
    /// <param name="request">Dados do cliente a ser criado</param>
    /// <param name="cancellationToken">Token de cancelamento</param>
    /// <returns>Cliente criado</returns>
    /// <response code="201">Cliente criado com sucesso</response>
    /// <response code="400">Dados inválidos ou cliente já existe</response>
    /// <response code="500">Erro interno do servidor</response>
    [HttpPost]
    [ProducesResponseType(typeof(ClienteDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> CriarCliente(
        [FromBody] CriarClienteRequest request, 
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var command = new CriarClienteCommand(request);
        var result = await _mediator.Send(command, cancellationToken);

        if (!result.Success)
        {
            var problemDetails = new ProblemDetails
            {
                Title = "Erro ao criar cliente",
                Status = StatusCodes.Status400BadRequest,
                Detail = string.Join("; ", result.Errors)
            };

            return BadRequest(problemDetails);
        }

        return CreatedAtAction(
            nameof(ObterClientePorId), 
            new { id = result.Data!.Id }, 
            result.Data);
    }

    /// <summary>
    /// Obtém um cliente por ID (placeholder para rota)
    /// </summary>
    /// <param name="id">ID do cliente</param>
    /// <returns>Cliente encontrado</returns>
    [HttpGet("{id:guid}")]
    [ApiExplorerSettings(IgnoreApi = true)] // Temporário - implementar depois
    public IActionResult ObterClientePorId(Guid id)
    {
        // Implementar depois - aqui apenas para ter a rota para CreatedAtAction
        return NotFound();
    }
}