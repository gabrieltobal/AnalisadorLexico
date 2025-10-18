unit uAnalisadorLexico;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Classes;

type
  TAnalisadorLexico = class
  private
    FMatriz: TArray<TArray<Integer>>;
    FAlfabeto: string;
    FEstadosFinais: TList<Integer>;
    function GetPosicaoAlfabeto(AChar: Char): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AlimentaMatriz(const ATokens: TStrings);
    function GetMatriz: TArray<TArray<Integer>>;
    function GetAlfabeto: string;
    function EhEstadoFinal(AEstado: Integer): Boolean;
  end;

implementation

{ TAnalisadorLexico }

constructor TAnalisadorLexico.Create;
begin
  inherited;
  FAlfabeto := 'abcdefghijklmnopqrstuvwxyz';
  // Garante que a lista de estados finais seja criada junto com o analisador.
  FEstadosFinais := TList<Integer>.Create;
end;

destructor TAnalisadorLexico.Destroy;
begin
  // Libera a memória da lista quando o analisador for destruído.
  FEstadosFinais.Free;
  inherited;
end;

procedure TAnalisadorLexico.AlimentaMatriz(const ATokens: TStrings);
var
  Token: string;
  EstadoAtual, ProximoEstado, Coluna, i, j, MaxEstados: Integer;
begin
  // Verificação de segurança: se esta mensagem aparecer, o problema é
  // na criação do objeto FAnalisador no formulário principal.
  if not Assigned(FEstadosFinais) then
    raise Exception.Create('Erro Crítico: A lista FEstadosFinais não foi inicializada!');

  FEstadosFinais.Clear;
  SetLength(FMatriz, 0);

  if ATokens.Count = 0 then Exit;

  // --- Lógica Melhorada: Pré-alocação da Matriz ---
  // 1. Calcula o número máximo de estados necessários.
  MaxEstados := 1; // Começa com o estado q0
  for i := 0 to ATokens.Count - 1 do
    for j := 1 to Length(ATokens[i]) do
      Inc(MaxEstados); // Adiciona um estado para cada letra de cada token (pior caso)

  // 2. Aloca a matriz de uma só vez com o tamanho máximo.
  SetLength(FMatriz, MaxEstados);
  for i := 0 to High(FMatriz) do
  begin
    SetLength(FMatriz[i], Length(FAlfabeto));
    for j := 0 to High(FMatriz[i]) do
      FMatriz[i][j] := -1; // -1 = Sem transição
  end;
  // --- Fim da Lógica Melhorada ---

  ProximoEstado := 1;
  for Token in ATokens do
  begin
    EstadoAtual := 0; // Sempre começa do estado inicial q0
    for i := 1 to Length(Token) do
    begin
      Coluna := GetPosicaoAlfabeto(Token[i]);
      if Coluna > -1 then
      begin
        // Se a transição ainda não existe, cria um novo estado para ela.
        if FMatriz[EstadoAtual, Coluna] = -1 then
        begin
          FMatriz[EstadoAtual, Coluna] := ProximoEstado;
          Inc(ProximoEstado);
        end;
        EstadoAtual := FMatriz[EstadoAtual, Coluna];
      end;
    end;

    // Marca o estado alcançado como final.
    if not FEstadosFinais.Contains(EstadoAtual) then
      FEstadosFinais.Add(EstadoAtual);
  end;

  // Opcional: Reduz a matriz para o tamanho exato utilizado.
  SetLength(FMatriz, ProximoEstado);
end;

function TAnalisadorLexico.EhEstadoFinal(AEstado: Integer): Boolean;
begin
  Result := FEstadosFinais.Contains(AEstado);
end;

function TAnalisadorLexico.GetAlfabeto: string;
begin
  Result := FAlfabeto;
end;

function TAnalisadorLexico.GetMatriz: TArray<TArray<Integer>>;
begin
  Result := FMatriz;
end;

function TAnalisadorLexico.GetPosicaoAlfabeto(AChar: Char): Integer;
begin
  Result := Pos(LowerCase(AChar), FAlfabeto) - 1;
end;

end.
