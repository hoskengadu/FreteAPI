using FreteAPI.Domain.Enums;
using FreteAPI.Domain.ValueObjects;

namespace FreteAPI.Domain.Entities;

/// <summary>
/// Entidade que representa um agendamento de frete
/// </summary>
public class Agendamento : BaseEntity
{
    public Guid ClienteId { get; private set; }
    public Guid ProfissionalId { get; private set; }
    public DateTime Data { get; private set; }
    public TimeOnly HoraInicio { get; private set; }
    public TimeOnly HoraFim { get; private set; }
    public StatusAgendamento Status { get; private set; }
    public string EnderecoOrigem { get; private set; } = string.Empty;
    public Localizacao LocalizacaoOrigem { get; private set; } = null!;

    // Relacionamentos
    public virtual Cliente Cliente { get; private set; } = null!;
    public virtual Profissional Profissional { get; private set; } = null!;

    // Para Entity Framework
    private Agendamento() : base() { EnderecoOrigem = string.Empty; LocalizacaoOrigem = null!; Cliente = null!; Profissional = null!; }

    public Agendamento(Guid clienteId, Guid profissionalId, DateTime data, TimeOnly horaInicio, 
                      TimeOnly horaFim, string enderecoOrigem, double latitudeOrigem, double longitudeOrigem)
        : base()
    {
        ValidarDataAgendamento(data);
        ValidarHorarios(horaInicio, horaFim);

        ClienteId = clienteId;
        ProfissionalId = profissionalId;
        Data = data;
        HoraInicio = horaInicio;
        HoraFim = horaFim;
        Status = StatusAgendamento.Pendente;
        SetEnderecoOrigem(enderecoOrigem);
        LocalizacaoOrigem = new Localizacao(latitudeOrigem, longitudeOrigem);
    }

    public void Confirmar()
    {
        if (Status != StatusAgendamento.Pendente)
            throw new InvalidOperationException("Apenas agendamentos pendentes podem ser confirmados");

        Status = StatusAgendamento.Confirmado;
    }

    public void Cancelar()
    {
        if (Status == StatusAgendamento.Cancelado)
            throw new InvalidOperationException("Agendamento já está cancelado");

        Status = StatusAgendamento.Cancelado;
    }

    public void AtualizarHorarios(TimeOnly horaInicio, TimeOnly horaFim)
    {
        if (Status != StatusAgendamento.Pendente)
            throw new InvalidOperationException("Apenas agendamentos pendentes podem ter horários alterados");

        ValidarHorarios(horaInicio, horaFim);
        HoraInicio = horaInicio;
        HoraFim = horaFim;
    }

    public void AtualizarData(DateTime novaData)
    {
        if (Status != StatusAgendamento.Pendente)
            throw new InvalidOperationException("Apenas agendamentos pendentes podem ter a data alterada");

        ValidarDataAgendamento(novaData);
        Data = novaData;
    }

    public TimeSpan Duracao => HoraFim.ToTimeSpan() - HoraInicio.ToTimeSpan();

    public DateTime DataHoraInicio => Data.Date.Add(HoraInicio.ToTimeSpan());

    public DateTime DataHoraFim => Data.Date.Add(HoraFim.ToTimeSpan());

    private static void ValidarDataAgendamento(DateTime data)
    {
        if (data.Date <= DateTime.Today)
            throw new ArgumentException("Data do agendamento deve ser futura");
    }

    private static void ValidarHorarios(TimeOnly horaInicio, TimeOnly horaFim)
    {
        if (horaInicio >= horaFim)
            throw new ArgumentException("Hora de início deve ser menor que hora de fim");

        var duracao = horaFim.ToTimeSpan() - horaInicio.ToTimeSpan();
        if (duracao.TotalMinutes < 30)
            throw new ArgumentException("Duração mínima do agendamento é 30 minutos");

        if (duracao.TotalHours > 12)
            throw new ArgumentException("Duração máxima do agendamento é 12 horas");
    }

    private void SetEnderecoOrigem(string endereco)
    {
        if (string.IsNullOrWhiteSpace(endereco))
            throw new ArgumentException("Endereço de origem é obrigatório");

        if (endereco.Length > 200)
            throw new ArgumentException("Endereço não pode exceder 200 caracteres");

        EnderecoOrigem = endereco.Trim();
    }
}