namespace FreteAPI.Application.Common;

/// <summary>
/// Resultado de operações que podem falhar
/// </summary>
public class Result<T>
{
    public bool Success { get; }
    public T? Data { get; }
    public IEnumerable<string> Errors { get; }

    private Result(bool success, T? data, IEnumerable<string> errors)
    {
        Success = success;
        Data = data;
        Errors = errors;
    }

    public static Result<T> SuccessResult(T data) => new(true, data, Array.Empty<string>());
    
    public static Result<T> FailureResult(params string[] errors) => new(false, default, errors);
    
    public static Result<T> FailureResult(IEnumerable<string> errors) => new(false, default, errors);

    public static implicit operator Result<T>(T data) => SuccessResult(data);
}

/// <summary>
/// Resultado de operações sem retorno de dados
/// </summary>
public class Result
{
    public bool Success { get; }
    public IEnumerable<string> Errors { get; }

    private Result(bool success, IEnumerable<string> errors)
    {
        Success = success;
        Errors = errors;
    }

    public static Result SuccessResult() => new(true, Array.Empty<string>());
    
    public static Result FailureResult(params string[] errors) => new(false, errors);
    
    public static Result FailureResult(IEnumerable<string> errors) => new(false, errors);
}