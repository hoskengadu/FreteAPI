using System.ComponentModel.DataAnnotations;

namespace FreteAPI.Application.Features.Clientes.DTOs;

/// <summary>
/// DTO para resposta de cliente
/// </summary>
public class ClienteDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Telefone { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public DateTime DataCriacao { get; set; }
}

/// <summary>
/// Request para criação de cliente
/// </summary>
public class CriarClienteRequest
{
    /// <summary>
    /// Nome completo do cliente
    /// </summary>
    [Required(ErrorMessage = "Nome é obrigatório")]
    [StringLength(100, ErrorMessage = "Nome não pode exceder 100 caracteres")]
    public string Nome { get; set; } = string.Empty;

    /// <summary>
    /// Email do cliente
    /// </summary>
    [Required(ErrorMessage = "Email é obrigatório")]
    [EmailAddress(ErrorMessage = "Email inválido")]
    public string Email { get; set; } = string.Empty;

    /// <summary>
    /// Telefone do cliente
    /// </summary>
    [Required(ErrorMessage = "Telefone é obrigatório")]
    [RegularExpression(@"^\d{10,11}$", ErrorMessage = "Telefone deve ter entre 10 e 11 dígitos")]
    public string Telefone { get; set; } = string.Empty;

    /// <summary>
    /// Latitude da localização do cliente
    /// </summary>
    [Range(-90, 90, ErrorMessage = "Latitude deve estar entre -90 e 90")]
    public double Latitude { get; set; }

    /// <summary>
    /// Longitude da localização do cliente
    /// </summary>
    [Range(-180, 180, ErrorMessage = "Longitude deve estar entre -180 e 180")]
    public double Longitude { get; set; }
}