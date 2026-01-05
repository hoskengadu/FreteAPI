using FreteAPI.Domain.ValueObjects;

namespace FreteAPI.Domain.Entities;

/// <summary>
/// Entidade que representa um cliente no sistema
/// </summary>
public class Cliente : BaseEntity
{
    public string Nome { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;
    public string Telefone { get; private set; } = string.Empty;
    public Localizacao Localizacao { get; private set; } = null!;

    // Para Entity Framework
    private Cliente() : base() { Nome = string.Empty; Email = string.Empty; Telefone = string.Empty; Localizacao = null!; }

    public Cliente(string nome, string email, string telefone, double latitude, double longitude)
        : base()
    {
        SetNome(nome);
        SetEmail(email);
        SetTelefone(telefone);
        Localizacao = new Localizacao(latitude, longitude);
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

        // Remove caracteres não numéricos
        var telefoneNumerico = new string(telefone.Where(char.IsDigit).ToArray());
        
        if (telefoneNumerico.Length < 10 || telefoneNumerico.Length > 11)
            throw new ArgumentException("Telefone deve ter entre 10 e 11 dígitos");

        Telefone = telefoneNumerico;
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