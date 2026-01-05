using AutoMapper;
using FreteAPI.Application.Features.Clientes.DTOs;
using FreteAPI.Application.Features.Profissionais.DTOs;
using FreteAPI.Application.Features.Agendamentos.DTOs;
using FreteAPI.Domain.Entities;

namespace FreteAPI.Application.Common;

/// <summary>
/// Perfil do AutoMapper para mapeamentos entre entidades e DTOs
/// </summary>
public class MappingProfile : Profile
{
    public MappingProfile()
    {
        // Cliente mappings
        CreateMap<Cliente, ClienteDto>()
            .ForMember(dest => dest.Latitude, opt => opt.MapFrom(src => src.Localizacao.Latitude))
            .ForMember(dest => dest.Longitude, opt => opt.MapFrom(src => src.Localizacao.Longitude));

        CreateMap<CriarClienteRequest, Cliente>()
            .ConstructUsing(src => new Cliente(src.Nome, src.Email, src.Telefone, src.Latitude, src.Longitude));

        // Profissional mappings
        CreateMap<Profissional, ProfissionalDto>()
            .ForMember(dest => dest.Latitude, opt => opt.MapFrom(src => src.Localizacao.Latitude))
            .ForMember(dest => dest.Longitude, opt => opt.MapFrom(src => src.Localizacao.Longitude));

        CreateMap<CriarProfissionalRequest, Profissional>()
            .ConstructUsing(src => new Profissional(src.Nome, src.Email, src.Telefone, src.Latitude, src.Longitude, src.RaioAtendimentoKm));

        CreateMap<Disponibilidade, DisponibilidadeDto>();

        // Agendamento mappings
        CreateMap<Agendamento, AgendamentoDto>()
            .ForMember(dest => dest.LatitudeOrigem, opt => opt.MapFrom(src => src.LocalizacaoOrigem.Latitude))
            .ForMember(dest => dest.LongitudeOrigem, opt => opt.MapFrom(src => src.LocalizacaoOrigem.Longitude))
            .ForMember(dest => dest.Cliente, opt => opt.MapFrom(src => src.Cliente))
            .ForMember(dest => dest.Profissional, opt => opt.MapFrom(src => src.Profissional));

        CreateMap<Agendamento, AgendamentoResumoDto>();
    }
}