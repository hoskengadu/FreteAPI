using Xunit;
using FluentAssertions;
using FreteAPI.Domain.Entities;

namespace FreteAPI.UnitTests.Domain;

public class ClienteTests
{
    [Fact]
    public void CriarCliente_ComDadosValidos_DeveRetornarSucesso()
    {
        // Arrange
        var nome = "João Silva";
        var email = "joao@email.com";
        var telefone = "11999999999";
        var latitude = -23.5505;
        var longitude = -46.6333;

        // Act
        var cliente = new Cliente(nome, email, telefone, latitude, longitude);

        // Assert
        cliente.Should().NotBeNull();
        cliente.Id.Should().NotBeEmpty();
        cliente.Nome.Should().Be(nome);
        cliente.Email.Should().Be(email.ToLower());
        cliente.Telefone.Should().Be(telefone);
        cliente.Localizacao.Latitude.Should().Be(latitude);
        cliente.Localizacao.Longitude.Should().Be(longitude);
        cliente.DataCriacao.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromSeconds(1));
    }

    [Theory]
    [InlineData("")]
    [InlineData(null)]
    [InlineData("   ")]
    public void CriarCliente_ComNomeInvalido_DeveLancarExcecao(string nomeInvalido)
    {
        // Arrange & Act & Assert
        var act = () => new Cliente(nomeInvalido, "email@test.com", "11999999999", -23.5505, -46.6333);
        act.Should().Throw<ArgumentException>()
           .WithMessage("Nome é obrigatório");
    }

    [Fact]
    public void CriarCliente_ComNomeMuitoLongo_DeveLancarExcecao()
    {
        // Arrange
        var nomeLongo = new string('a', 101);

        // Act & Assert
        var act = () => new Cliente(nomeLongo, "email@test.com", "11999999999", -23.5505, -46.6333);
        act.Should().Throw<ArgumentException>()
           .WithMessage("Nome não pode exceder 100 caracteres");
    }

    [Theory]
    [InlineData("")]
    [InlineData(null)]
    [InlineData("   ")]
    [InlineData("email_invalido")]
    [InlineData("email@")]
    [InlineData("@domain.com")]
    public void CriarCliente_ComEmailInvalido_DeveLancarExcecao(string emailInvalido)
    {
        // Act & Assert
        var act = () => new Cliente("Nome", emailInvalido, "11999999999", -23.5505, -46.6333);
        act.Should().Throw<ArgumentException>();
    }

    [Theory]
    [InlineData("")]
    [InlineData(null)]
    [InlineData("   ")]
    public void CriarCliente_ComTelefoneVazio_DeveLancarExcecao(string telefoneVazio)
    {
        // Act & Assert
        var act = () => new Cliente("Nome", "email@test.com", telefoneVazio, -23.5505, -46.6333);
        act.Should().Throw<ArgumentException>()
           .WithMessage("Telefone é obrigatório");
    }

    [Theory]
    [InlineData("123")]
    [InlineData("123456789")]
    [InlineData("123456789012")]
    public void CriarCliente_ComTelefoneComTamanhoInvalido_DeveLancarExcecao(string telefoneInvalido)
    {
        // Act & Assert
        var act = () => new Cliente("Nome", "email@test.com", telefoneInvalido, -23.5505, -46.6333);
        act.Should().Throw<ArgumentException>()
           .WithMessage("Telefone deve ter entre 10 e 11 dígitos");
    }

    [Fact]
    public void AtualizarDados_ComDadosValidos_DeveAtualizarCorretamente()
    {
        // Arrange
        var cliente = new Cliente("Nome", "email@test.com", "11999999999", -23.5505, -46.6333);
        var novoNome = "Novo Nome";
        var novoEmail = "novo@email.com";
        var novoTelefone = "11888888888";

        // Act
        cliente.AtualizarDados(novoNome, novoEmail, novoTelefone);

        // Assert
        cliente.Nome.Should().Be(novoNome);
        cliente.Email.Should().Be(novoEmail.ToLower());
        cliente.Telefone.Should().Be(novoTelefone);
    }

    [Fact]
    public void AtualizarLocalizacao_ComCoordenadasValidas_DeveAtualizarCorretamente()
    {
        // Arrange
        var cliente = new Cliente("Nome", "email@test.com", "11999999999", -23.5505, -46.6333);
        var novaLatitude = -23.5600;
        var novaLongitude = -46.6400;

        // Act
        cliente.AtualizarLocalizacao(novaLatitude, novaLongitude);

        // Assert
        cliente.Localizacao.Latitude.Should().Be(novaLatitude);
        cliente.Localizacao.Longitude.Should().Be(novaLongitude);
    }
}