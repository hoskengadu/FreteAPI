using System.ComponentModel.DataAnnotations;
using FreteAPI.Application.Features.Clientes.DTOs;
using FreteAPI.Application.Features.Profissionais.DTOs;
using FreteAPI.Domain.Enums;

namespace FreteAPI.Application.Features.Agendamentos.DTOs;

/// <summary>
/// DTO completo para resposta de agendamento
/// </summary>
public class AgendamentoDto
{
    public Guid Id { get; set; }
    public Guid ClienteId { get; set; }
    public Guid ProfissionalId { get; set; }
    public DateTime Data { get; set; }
    public TimeOnly HoraInicio { get; set; }
    public TimeOnly HoraFim { get; set; }
    public StatusAgendamento Status { get; set; }
    public string EnderecoOrigem { get; set; } = string.Empty;
    public double LatitudeOrigem { get; set; }
    public double LongitudeOrigem { get; set; }
    public DateTime DataCriacao { get; set; }
    
    public ClienteDto? Cliente { get; set; }
    public ProfissionalDto? Profissional { get; set; }
}

/// <summary>
/// DTO resumido para listagens de agendamento
/// </summary>
public class AgendamentoResumoDto
{
    public Guid Id { get; set; }
    public Guid ClienteId { get; set; }
    public Guid ProfissionalId { get; set; }
    public DateTime Data { get; set; }
    public TimeOnly HoraInicio { get; set; }
    public TimeOnly HoraFim { get; set; }
    public StatusAgendamento Status { get; set; }
    public string EnderecoOrigem { get; set; } = string.Empty;
    public DateTime DataCriacao { get; set; }
}

/// <summary>
/// Request para criação de agendamento
/// </summary>
public class CriarAgendamentoRequest
{
    /// <summary>
    /// ID do cliente
    /// </summary>
    [Required(ErrorMessage = "Cliente é obrigatório")]
    public Guid ClienteId { get; set; }

    /// <summary>
    /// ID do profissional
    /// </summary>
    [Required(ErrorMessage = "Profissional é obrigatório")]
    public Guid ProfissionalId { get; set; }

    /// <summary>
    /// Data do agendamento
    /// </summary>
    [Required(ErrorMessage = "Data é obrigatória")]
    public DateTime Data { get; set; }

    /// <summary>
    /// Hora de início do serviço
    /// </summary>
    [Required(ErrorMessage = "Hora de início é obrigatória")]
    public TimeOnly HoraInicio { get; set; }

    /// <summary>
    /// Hora de fim do serviço
    /// </summary>
    [Required(ErrorMessage = "Hora de fim é obrigatória")]
    public TimeOnly HoraFim { get; set; }

    /// <summary>
    /// Endereço de origem do frete
    /// </summary>
    [Required(ErrorMessage = "Endereço de origem é obrigatório")]
    [StringLength(200, ErrorMessage = "Endereço não pode exceder 200 caracteres")]
    public string EnderecoOrigem { get; set; } = string.Empty;

    /// <summary>
    /// Latitude do endereço de origem
    /// </summary>
    [Range(-90, 90, ErrorMessage = "Latitude deve estar entre -90 e 90")]
    public double LatitudeOrigem { get; set; }

    /// <summary>
    /// Longitude do endereço de origem
    /// </summary>
    [Range(-180, 180, ErrorMessage = "Longitude deve estar entre -180 e 180")]
    public double LongitudeOrigem { get; set; }
}