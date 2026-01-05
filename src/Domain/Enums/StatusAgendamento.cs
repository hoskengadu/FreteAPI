namespace FreteAPI.Domain.Enums;

/// <summary>
/// Status possíveis para um agendamento
/// </summary>
public enum StatusAgendamento
{
    /// <summary>
    /// Agendamento criado, aguardando confirmação
    /// </summary>
    Pendente = 1,

    /// <summary>
    /// Agendamento confirmado pelo profissional
    /// </summary>
    Confirmado = 2,

    /// <summary>
    /// Agendamento cancelado
    /// </summary>
    Cancelado = 3
}