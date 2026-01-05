using FreteAPI.Domain.ValueObjects;

namespace FreteAPI.Domain.Entities;

/// <summary>
/// Entidade que representa um profissional (freteiro) no sistema
/// </summary>
public class Profissional : BaseEntity
{
    public string Nome { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;
    public string Telefone { get; private set; } = string.Empty;
    public Localizacao Localizacao { get; private set; } = null!;
    public double RaioAtendimentoKm { get; private set; }
    public bool Ativo { get; private set; }

    private readonly List<Disponibilidade> _disponibilidades = new();
    private readonly List<Agendamento> _agendamentos = new();

    public IReadOnlyCollection<Disponibilidade> Disponibilidades => _disponibilidades.AsReadOnly();
    public IReadOnlyCollection<Agendamento> Agendamentos => _agendamentos.AsReadOnly();

    // Para Entity Framework
    private Profissional() : base() { Nome = string.Empty; Email = string.Empty; Telefone = string.Empty; Localizacao = null!; }

    public Profissional(string nome, string email, string telefone, double latitude, double longitude, double raioAtendimentoKm)
        : base()
    {
        SetNome(nome);
        SetEmail(email);
        SetTelefone(telefone);
        Localizacao = new Localizacao(latitude, longitude);
        SetRaioAtendimento(raioAtendimentoKm);
        Ativo = true;
    }

    public void AtualizarDados(string nome, string email, string telefone)
    {
        SetNome(nome);
        SetEmail(email);
        SetTelefone(telefone);
    }

    public void AtualizarLocalizacao(double latitude, double longitude)
    {
        Localizacao = new Localizacao(latitude, longitude);
    }

    public void AtualizarRaioAtendimento(double raioKm)
    {
        SetRaioAtendimento(raioKm);
    }

    public void Ativar() => Ativo = true;
    public void Desativar() => Ativo = false;

    public void AdicionarDisponibilidade(DayOfWeek diaSemana, TimeOnly horaInicio, TimeOnly horaFim)
    {
        if (horaInicio >= horaFim)
            throw new ArgumentException("Hora de início deve ser menor que hora de fim");

        var disponibilidadeExistente = _disponibilidades
            .FirstOrDefault(d => d.DiaSemana == diaSemana);

        if (disponibilidadeExistente != null)
        {
            disponibilidadeExistente.AtualizarHorarios(horaInicio, horaFim);
        }
        else
        {
            var disponibilidade = new Disponibilidade(Id, diaSemana, horaInicio, horaFim);
            _disponibilidades.Add(disponibilidade);
        }
    }

    public void RemoverDisponibilidade(DayOfWeek diaSemana)
    {
        var disponibilidade = _disponibilidades.FirstOrDefault(d => d.DiaSemana == diaSemana);
        if (disponibilidade != null)
        {
            _disponibilidades.Remove(disponibilidade);
        }
    }

    public bool EstaDisponivel(DateTime dataHora, TimeSpan duracao)
    {
        if (!Ativo) return false;

        var diaSemana = dataHora.DayOfWeek;
        var hora = TimeOnly.FromDateTime(dataHora);
        var horaFim = hora.Add(duracao);

        var disponibilidade = _disponibilidades
            .FirstOrDefault(d => d.DiaSemana == diaSemana);

        if (disponibilidade == null) return false;

        if (hora < disponibilidade.HoraInicio || horaFim > disponibilidade.HoraFim)
            return false;

        // Verifica conflitos com agendamentos existentes
        return !_agendamentos.Any(a => 
            a.Data.Date == dataHora.Date &&
            a.Status != Enums.StatusAgendamento.Cancelado &&
            !(TimeOnly.FromDateTime(dataHora.Add(duracao)) <= a.HoraInicio ||
              hora >= a.HoraFim));
    }

    internal void AdicionarAgendamento(Agendamento agendamento)
    {
        _agendamentos.Add(agendamento);
    }

    private void SetNome(string nome)
    {
        if (string.IsNullOrWhiteSpace(nome))
            throw new ArgumentException("Nome é obrigatório");
        
        if (nome.Length > 100)
            throw new ArgumentException("Nome não pode exceder 100 caracteres");

        Nome = nome.Trim();
    }

    private void SetEmail(string email)
    {
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("Email é obrigatório");

        if (!IsValidEmail(email))
            throw new ArgumentException("Email inválido");

        Email = email.Trim().ToLower();
    }

    private void SetTelefone(string telefone)
    {
        if (string.IsNullOrWhiteSpace(telefone))
            throw new ArgumentException("Telefone é obrigatório");

        var telefoneNumerico = new string(telefone.Where(char.IsDigit).ToArray());
        
        if (telefoneNumerico.Length < 10 || telefoneNumerico.Length > 11)
            throw new ArgumentException("Telefone deve ter entre 10 e 11 dígitos");

        Telefone = telefoneNumerico;
    }

    private void SetRaioAtendimento(double raioKm)
    {
        if (raioKm <= 0)
            throw new ArgumentException("Raio de atendimento deve ser maior que zero");

        if (raioKm > 500)
            throw new ArgumentException("Raio de atendimento não pode exceder 500km");

        RaioAtendimentoKm = raioKm;
    }

    private static bool IsValidEmail(string email)
    {
        try
        {
            var addr = new System.Net.Mail.MailAddress(email);
            return addr.Address == email;
        }
        catch
        {
            return false;
        }
    }
}