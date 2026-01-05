namespace FreteAPI.Domain.Entities;

/// <summary>
/// Entidade que representa a disponibilidade de um profissional
/// </summary>
public class Disponibilidade : BaseEntity
{
    public Guid ProfissionalId { get; private set; }
    public DayOfWeek DiaSemana { get; private set; }
    public TimeOnly HoraInicio { get; private set; }
    public TimeOnly HoraFim { get; private set; }

    // Relacionamento com Profissional
    public virtual Profissional Profissional { get; private set; } = null!;

    // Para Entity Framework
    private Disponibilidade() : base() { Profissional = null!; }

    public Disponibilidade(Guid profissionalId, DayOfWeek diaSemana, TimeOnly horaInicio, TimeOnly horaFim)
        : base()
    {
        if (horaInicio >= horaFim)
            throw new ArgumentException("Hora de início deve ser menor que hora de fim");

        ProfissionalId = profissionalId;
        DiaSemana = diaSemana;
        HoraInicio = horaInicio;
        HoraFim = horaFim;
    }

    public void AtualizarHorarios(TimeOnly horaInicio, TimeOnly horaFim)
    {
        if (horaInicio >= horaFim)
            throw new ArgumentException("Hora de início deve ser menor que hora de fim");

        HoraInicio = horaInicio;
        HoraFim = horaFim;
    }

    public bool ContemHorario(TimeOnly hora)
    {
        return hora >= HoraInicio && hora <= HoraFim;
    }

    public bool ContemPeriodo(TimeOnly inicio, TimeOnly fim)
    {
        return inicio >= HoraInicio && fim <= HoraFim;
    }
}