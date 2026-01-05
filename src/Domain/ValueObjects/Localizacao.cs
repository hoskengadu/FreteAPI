namespace FreteAPI.Domain.ValueObjects;

/// <summary>
/// Value Object que representa uma localização geográfica
/// </summary>
public record Localizacao
{
    public double Latitude { get; }
    public double Longitude { get; }

    public Localizacao(double latitude, double longitude)
    {
        ValidarCoordenadas(latitude, longitude);
        Latitude = latitude;
        Longitude = longitude;
    }

    /// <summary>
    /// Calcula a distância em quilômetros entre duas localizações usando a fórmula de Haversine
    /// </summary>
    public double DistanciaEmKmPara(Localizacao outraLocalizacao)
    {
        const double raioTerraKm = 6371;
        
        var lat1Rad = DegreesToRadians(Latitude);
        var lat2Rad = DegreesToRadians(outraLocalizacao.Latitude);
        var deltaLatRad = DegreesToRadians(outraLocalizacao.Latitude - Latitude);
        var deltaLonRad = DegreesToRadians(outraLocalizacao.Longitude - Longitude);

        var a = Math.Sin(deltaLatRad / 2) * Math.Sin(deltaLatRad / 2) +
                Math.Cos(lat1Rad) * Math.Cos(lat2Rad) *
                Math.Sin(deltaLonRad / 2) * Math.Sin(deltaLonRad / 2);
        
        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        
        return raioTerraKm * c;
    }

    /// <summary>
    /// Verifica se esta localização está dentro do raio especificado de outra localização
    /// </summary>
    public bool EstaDentroDoRaio(Localizacao outraLocalizacao, double raioKm)
    {
        return DistanciaEmKmPara(outraLocalizacao) <= raioKm;
    }

    private static void ValidarCoordenadas(double latitude, double longitude)
    {
        if (latitude < -90 || latitude > 90)
            throw new ArgumentException("Latitude deve estar entre -90 e 90 graus");

        if (longitude < -180 || longitude > 180)
            throw new ArgumentException("Longitude deve estar entre -180 e 180 graus");
    }

    private static double DegreesToRadians(double degrees)
    {
        return degrees * Math.PI / 180;
    }

    public override string ToString()
    {
        return $"Lat: {Latitude:F6}, Lon: {Longitude:F6}";
    }
}