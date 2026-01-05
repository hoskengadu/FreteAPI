using System.ComponentModel.DataAnnotations;

namespace FreteAPI.Application.Features.Profissionais.DTOs;

/// <summary>
/// DTO para resposta de profissional
/// </summary>
public class ProfissionalDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Telefone { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public double RaioAtendimentoKm { get; set; }
    public bool Ativo { get; set; }
    public DateTime DataCriacao { get; set; }
    public List<DisponibilidadeDto> Disponibilidades { get; set; } = new();
}

/// <summary>
/// DTO para profissional próximo com distância
/// </summary>
public class ProfissionalProximoDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Telefone { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public double RaioAtendimentoKm { get; set; }
    public double DistanciaKm { get; set; }
    public List<DisponibilidadeDto> Disponibilidades { get; set; } = new();
}

/// <summary>
/// DTO para disponibilidade
/// </summary>
public class DisponibilidadeDto
{
    public Guid Id { get; set; }
    public DayOfWeek DiaSemana { get; set; }
    public TimeOnly HoraInicio { get; set; }
    public TimeOnly HoraFim { get; set; }
}

/// <summary>
/// Request para criação de profissional
/// </summary>
public class CriarProfissionalRequest
{
    /// <summary>
    /// Nome completo do profissional
    /// </summary>
    [Required(ErrorMessage = "Nome é obrigatório")]
    [StringLength(100, ErrorMessage = "Nome não pode exceder 100 caracteres")]
    public string Nome { get; set; } = string.Empty;

    /// <summary>
    /// Email do profissional
    /// </summary>
    [Required(ErrorMessage = "Email é obrigatório")]
    [EmailAddress(ErrorMessage = "Email inválido")]
    public string Email { get; set; } = string.Empty;

    /// <summary>
    /// Telefone do profissional
    /// </summary>
    [Required(ErrorMessage = "Telefone é obrigatório")]
    [RegularExpression(@"^\d{10,11}$", ErrorMessage = "Telefone deve ter entre 10 e 11 dígitos")]
    public string Telefone { get; set; } = string.Empty;

    /// <summary>
    /// Latitude da localização do profissional
    /// </summary>
    [Range(-90, 90, ErrorMessage = "Latitude deve estar entre -90 e 90")]
    public double Latitude { get; set; }

    /// <summary>
    /// Longitude da localização do profissional
    /// </summary>
    [Range(-180, 180, ErrorMessage = "Longitude deve estar entre -180 e 180")]
    public double Longitude { get; set; }

    /// <summary>
    /// Raio de atendimento em quilômetros
    /// </summary>
    [Range(0.1, 500, ErrorMessage = "Raio de atendimento deve estar entre 0.1 e 500 km")]
    public double RaioAtendimentoKm { get; set; }
}

/// <summary>
/// Request para adicionar disponibilidade
/// </summary>
public class AdicionarDisponibilidadeRequest
{
    /// <summary>
    /// Dia da semana
    /// </summary>
    [Required(ErrorMessage = "Dia da semana é obrigatório")]
    public DayOfWeek DiaSemana { get; set; }

    /// <summary>
    /// Hora de início (formato: HH:mm)
    /// </summary>
    [Required(ErrorMessage = "Hora de início é obrigatória")]
    public TimeOnly HoraInicio { get; set; }

    /// <summary>
    /// Hora de fim (formato: HH:mm)
    /// </summary>
    [Required(ErrorMessage = "Hora de fim é obrigatória")]
    public TimeOnly HoraFim { get; set; }
}

/// <summary>
/// Request para buscar profissionais próximos
/// </summary>
public class BuscarProfissionaisProximosRequest
{
    /// <summary>
    /// Latitude da localização de origem
    /// </summary>
    [Range(-90, 90, ErrorMessage = "Latitude deve estar entre -90 e 90")]
    public double Latitude { get; set; }

    /// <summary>
    /// Longitude da localização de origem
    /// </summary>
    [Range(-180, 180, ErrorMessage = "Longitude deve estar entre -180 e 180")]
    public double Longitude { get; set; }

    /// <summary>
    /// Data e hora desejada para o serviço
    /// </summary>
    [Required(ErrorMessage = "Data e hora são obrigatórias")]
    public DateTime DataHora { get; set; }

    /// <summary>
    /// Duração estimada do serviço em minutos
    /// </summary>
    [Range(30, 720, ErrorMessage = "Duração deve estar entre 30 minutos e 12 horas")]
    public int DuracaoMinutos { get; set; } = 60;
}