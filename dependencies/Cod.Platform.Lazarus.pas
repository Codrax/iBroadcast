{$SCOPEDENUMS ON}
{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

unit Cod.Platform.Lazarus;

interface
uses
  {$IFDEF MSWINDOWS}Windows, ShellAPI, {$ELSE}BaseUnix, {$ENDIF}
  SysUtils, Classes, Types, FileUtil, streamex,
  Math, Graphics;

{$IFDEF FPC}
type
  TProc = procedure;

  {$SCOPEDENUMS ON}
  THorzRectAlign = (Center, Left, Right);
  TVertRectAlign = (Center, Top, Bottom);
  {$SCOPEDENUMS OFF}

  TAlphaColor = type Cardinal;

  TPNGImage = TPortableNetworkGraphic;

  LCID = DWORD;
  TLocaleID = LCID;

  { TBitMapHelper }
  TBitMapHelper = class helper for TBitmap
      class function Create(AWidth, AHeight: integer): TBitMap; overload; static; inline;
  end;

  { TFormatSettingsHelper }

  TFormatSettingsHelper = record helper for TFormatSettings
      class function Create: TFormatSettings; overload; static; inline;
      class function Create(Locale: TLocaleID): TFormatSettings; overload; platform; static;
      class function Create(const LocaleName: string): TFormatSettings; overload; static;
  end;

  { TPath }
  TPath = record
  public
    class function Combine(const Path1, Path2: string): string; static; overload;
    class function Combine(const Path1, Path2, Path3: string): string; static; overload;
    class function GetDirectoryName(const FileName: string): string; static;
    class function GetExtension(const FileName: string): string; static;
    class function GetFileName(const FileName: string): string; static;
    class function GetFileNameWithoutExtension(const FileName: string): string; static;
    class function GetFullPath(const Path: string): string; static;
    class function GetTempPath: string; static;
    class function GetTempFileName: string; static;
    class function GetHomePath: string; static;
    class function GetDesktopPath: string; static;
    class function ChangeExtension(const Path, Extension: string): string; static;
    class function HasExtension(const Path: string): Boolean; static;
    class function IsPathRooted(const Path: string): Boolean; static;
    class function IsRelativePath(const Path: string): Boolean; static;

    class function GetInvalidFileNameChars: TCharArray; static;
    class function GetInvalidPathChars: TCharArray; static;

    class function GetRandomFileName: string; static;

    class function GetDirectorySeparatorChar: Char; static;
    class function GetAltDirectorySeparatorChar: Char; static;

    //
    class property AltDirectorySeparatorChar: Char read GetAltDirectorySeparatorChar;
    class property DirectorySeparatorChar: Char read GetDirectorySeparatorChar;
  end;

  { TDirectory }
  {$SCOPEDENUMS OFF}
  TSearchOption = (soTopDirectoryOnly, soAllDirectories); 
  {$SCOPEDENUMS ON}

  TDirectory = record
  public
    class function Exists(const Path: string): Boolean; static;
    class function CreateDirectory(const Path: string): Boolean; static;
    class function GetCurrentDirectory: string; static;
    class function SetCurrentDirectory(const Path: string): Boolean; static;
    class function GetParent(const Path: string): string; static;

    class procedure Copy(const SourceDirName, DestDirName: string); overload; static;
    class procedure Move(const SourceDirName, DestDirName: string); static;

    class procedure Delete(const Path: string); overload; static;
    class procedure Delete(const Path: string;
      const Recursive: Boolean); overload; static;

    class function GetFiles(const Path: string;
          const SearchPattern: string='*';
          const SearchOption: TSearchOption=TSearchOption.soTopDirectoryOnly): TStringDynArray; overload;static;

    class function GetDirectories(const Path: string;
          const SearchOption: TSearchOption=TSearchOption.soTopDirectoryOnly): TStringDynArray; overload; static;
  end;

  { TFile }
  {$SCOPEDENUMS OFF}
  TFileMode = (fmCreateNew, fmCreate, fmOpen, fmOpenOrCreate, fmTruncate,
    fmAppend);      
  {$SCOPEDENUMS ON}

  TFile = record
    class function Create(const Path: string): TFileStream; overload; static;
    class function Create(const Path: string;
      const BufferSize: Integer): TFileStream; overload; static;

    class procedure AppendAllText(const Path, Contents: string); overload; static;

    class procedure Copy(const SourceFileName, DestFileName: string);
      overload; static;
    class procedure Copy(const SourceFileName, DestFileName: string;
      const Overwrite: Boolean); overload; static;

    class function CreateSymLink(const Link, Target: string): Boolean; static;

    class procedure Delete(const Path: string); static;

    class function Exists(const Path: string;
      FollowLink: Boolean = True): Boolean; static;

    class function GetSize(const Path: string): Int64; static;

    class procedure Move(SourceFileName, DestFileName: string); static;

    class function Open(const Path: string;
      const Mode: word): TFileStream; overload; static;

    class function GetCreationTime(const Path: string): TDateTime; static;
    class function GetLastAccessTime(const Path: string): TDateTime; static;
    class function GetLastWriteTime(const Path: string): TDateTime; static;

    class procedure SetCreationTime(const Path: string;
        const CreationTime: TDateTime); static;
    class procedure SetLastAccessTime(const Path: string;
        const LastAccessTime: TDateTime); static;
    class procedure SetLastWriteTime(const Path: string;
        const LastWriteTime: TDateTime); static;

    class function OpenRead(const Path: string): TFileStream; static;
    class function OpenWrite(const Path: string): TFileStream; static;

    class function ReadAllBytes(const Path: string): TBytes; static;
    class function ReadAllLines(const Path: string): TStringDynArray;
      overload; static;
    class function ReadAllText(const Path: string): string;
      overload; static;

    class procedure WriteAllBytes(const Path: string;
      const Bytes: TBytes); static;

    class procedure WriteAllLines(const Path: string;
      const Contents: TStringDynArray); overload; static;

    class procedure WriteAllText(const Path, Contents: string);
      overload; static;
  end;

  PPointF = ^TPointF;
  { TPointFHelper }
  TPointFHelper = record helper for TPointF
    procedure Offset(const ADeltaX, ADeltaY: Single); overload; inline;

    function EqualsTo(const Point: TPointF; const Epsilon: Single = 0): Boolean;

    function Normalize: TPointF;
    function Rotate(const AAngle: Single): TPointF;
    function Reflect(const APoint: TPointF): TPointF; inline;
    function MidPoint(const APoint: TPointF): TPointF; inline;
    function AngleCosine(const APoint: TPointF): Single;
    function Angle(const APoint: TPointF): Single;
  end;

  PSizeF = ^TSizeF;
    TSizeF = record
      cx: Single;
      cy: Single;
    public
      constructor Create(P: TSizeF); overload;
      constructor Create(const X, Y: Single); overload;
      // operator overloads
      class operator Equal(const Lhs, Rhs: TSizeF): Boolean;
      class operator NotEqual(const Lhs, Rhs: TSizeF): Boolean;
      class operator Add(const Lhs, Rhs: TSizeF): TSizeF;
      class operator Subtract(const Lhs, Rhs: TSizeF): TSizeF;

      class operator Implicit(const Size: TSizeF): TPointF;
      class operator Implicit(const Point: TPointF): TSizeF;
      class operator Implicit(const Size: TSize): TSizeF;

      function Ceiling: TSize;
      function Truncate: TSize;
      function Round: TSize;

      // metods
      function Add(const Point: TSizeF): TSizeF;
      function Subtract(const Point: TSizeF): TSizeF;
      function Distance(const P2: TSizeF): Double;
      function IsZero: Boolean;
      /// <summary>Returns size with swapped width and height</summary>
      function SwapDimensions: TSizeF;
      // properties
      property Width: Single read cx write cx;
      property Height: Single read cy write cy;
    end;

  PRectF = ^TRectF;
  { TRectFHelper }
  TRectFHelper = record helper for TRectF
  private
    function GetSize: TSizeF;
    procedure SetSize(const Value: TSizeF);
    function GetLocation: TPointF;
  public
    constructor Create(const Origin: TPointF); overload;                              // empty rect at given origin
    constructor Create(const Origin: TPointF; const Width, Height: Single); overload; // at TPoint of origin with width and height
    constructor Create(const Left, Top, Right, Bottom: Single); overload;             // at Left, Top, Right, and Bottom
    constructor Create(const P1, P2: TPointF; Normalize: Boolean = False); overload;  // with corners specified by p1 and p2
    constructor Create(const R: TRectF; Normalize: Boolean = False); overload;
    constructor Create(const R: TRect; Normalize: Boolean = False); overload;

    class function Empty: TRectF; inline; static;
    //makes sure TopLeft is above and to the left of BottomRight
    procedure NormalizeRect;

    //returns true if left = right or top = bottom
    function IsEmpty: Boolean;

    //returns true if the point is inside the rect
    function Contains(const Pt: TPointF): Boolean; overload;

    // returns true if the rect encloses R completely
    function Contains(const R: TRectF): Boolean; overload;

    // returns true if any part of the rect covers R
    function IntersectsWith(const R: TRectF): Boolean;

    // computes an intersection of R1 and R2
    class function Intersect(const R1: TRectF; const R2: TRectF): TRectF; overload; static;

    // replaces current rectangle with its intersection with R
    procedure Intersect(const R: TRectF); overload;

    // computes a union of R1 and R2
    class function Union(const R1: TRectF; const R2: TRectF): TRectF; overload; static;

    // replaces current rectangle with its union with R
    procedure Union(const R: TRectF); overload;

    // creates a minimal rectangle that contains all points from array Points
    class function Union(const Points: Array of TPointF): TRectF; overload; static;

    // offsets the rectangle origin relative to current position
    procedure Offset(const DX, DY: Single); overload;
    procedure Offset(const Point: TPointF); overload;

    // sets new origin
    procedure SetLocation(const X, Y: Single); overload;
    procedure SetLocation(const Point: TPointF); overload;

    // inflate
    procedure Inflate(const DX, DY: Single); overload;
    procedure Inflate(const DL, DT, DR, DB: Single); overload;


    function CenterPoint: TPointF;
    function Ceiling: TRect;
    function Truncate: TRect;
    function Round: TRect;

    function EqualsTo(const R: TRectF; const Epsilon: Single = 0): Boolean;

    property Size: TSizeF read GetSize write SetSize;

    property Location: TPointF read GetLocation write SetLocation;
  end;

  TQueue<T> = class
  private
    FItems: array of T;
    FHead: Integer;
    FTail: Integer;
    function GetCount: Integer;
  public
    constructor Create;
    procedure Enqueue(const Item: T);
    function Dequeue: T;
    property Count: Integer read GetCount;
  end;

///  SYS UTILS
function IsRelativePath(const Path: string): Boolean;

///  TYPES
function Min(const A, B: Single): Single; overload; inline;

function Max(const A, B: Single): Single; overload; inline;


function EqualRect(const R1, R2: TRectF): Boolean; overload;

function RectF(Left, Top, Right, Bottom: Single): TRectF; inline; overload;
function NormalizeRectF(const Pts: array of TPointF): TRectF; overload;
function NormalizeRect(const ARect: TRectF): TRectF; overload;
function RectWidth(const Rect: TRect): Integer; inline; overload;
function RectWidth(const Rect: TRectF): Single; inline; overload;
function RectHeight(const Rect: TRect): Integer; inline; overload;
function RectHeight(const Rect: TRectF): Single; inline; overload;
function RectCenter(var R: TRect; const Bounds: TRect): TRect; overload;
function RectCenter(var R: TRectF; const Bounds: TRectF): TRectF; overload;
// Bounds
// Point
function PointF(X, Y: Single): TPointF; inline; overload;
function MinPoint(const P1, P2: TPointF): TPointF; overload;
function MinPoint(const P1, P2: TPoint): TPoint; overload;
function ScalePoint(const P: TPointF; dX, dY: Single): TPointF; overload;
function ScalePoint(const P: TPoint; dX, dY: Single): TPoint; overload;
// SmallPoint
// PtInRect
function PtInRect(const Rect: TRectF; const P: TPointF): Boolean; overload;
// IntersectRect
function IntersectRect(const Rect1, Rect2: TRectF): Boolean; overload;
function IntersectRect(out Rect: TRectF; const R1, R2: TRectF): Boolean; overload;
// UnionRect
function UnionRect(out Rect: TRectF; const R1, R2: TRectF): Boolean; overload;
// IsRectEmpty
function IsRectEmpty(const Rect: TRectF): Boolean; overload;
// OffsetRect
function OffsetRect(var R: TRectF; DX, DY: Single): Boolean; overload;
procedure MultiplyRect(var R: TRectF; const DX, DY: Single);
procedure InflateRect(var R: TRectF; const DX, DY: Single); overload;
// InflateRect
// CenterPoint
// SplitRect
function IntersectRectF(out Rect: TRectF; const R1, R2: TRectF): Boolean;
function UnionRectF(out Rect: TRectF; const R1, R2: TRectF): Boolean;


const
///  SHELLAPI
  FOF_NO_UI = FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOERRORUI or FOF_NOCONFIRMMKDIR;

{$ENDIF}
implementation

{$IFDEF FPC}
const
  // Single, 4bytes:    1-sign,  8-exp, 23-mantissa - 2^23 ~ 1E3*1E3*8 ~ 8E6 (really 8388608),
  //                          relative resolution = 1/(8E6) ~ 1.25E-7 (really 1.19E-7),
  //                          zero = 1/(2^(2^(8-1)) = 1/2^128 ~ 0.0625E-36 ~ 6.25E-38 (really 3E-39)
  FuzzFactorSingle = 10;
  SingleResolution: Single = 1.25E-7 * FuzzFactorSingle; // this is relative resolution of mantissa
  SingleZero: Single = 6.25E-37; // 6.25E-38 * FuzzFactorSingle;
  // Double, 8bytes:    1-sign, 11-exp, 52-mantissa - 2^52 ~ 1E3*1E3*1E3*1E3*1E3*4 = 4E15,
  //                             relative resolution = 2.5*E-16
  // FuzzFactorDouble = 10;
  // DoubleResolution: Double = 2.5E-16 * FuzzFactorDouble;
  // Extended, 10bytes: 1-sign, 15-exp, 64-mantissa - relative resolution = 0.0625*E-18
  // Real, 6bytes:      1-sign,  7-exp, 40-mantissa - 1.0*E-12 - deprecated

  // Example: for mantissa length=2 (0,xx - binary) resolution in mantissa is the last binary bite 0,01b = 1/4,
  //  for mantissa length=3 (0,xxx - binary) resolution in mantissa is the last binary bite 0,001b = 1/8, etc
  //  really the high digit is assumed to 1 (0,1xx or 0,1xxx) and the precision is 2 times higher

  Epsilon: Single = 1E-40;
  {$EXTERNALSYM Epsilon}
  {$HPPEMIT 'extern const System::Single Epsilon /*= 1E-40*/;'}
  Epsilon2: Single = 1E-30;


function SameValue(const A, B: Single; Epsilon: Single = 0): Boolean;
begin
{$EXCESSPRECISION OFF}
  if Epsilon = 0 then
    Epsilon := Max(Abs(A), Abs(B)) * SingleResolution;
  if Epsilon = 0 then
     Epsilon := SingleZero; // both A and B are very little, Epsilon was 0 because of normalization
  if A > B then
    Result := (A - B) <= Epsilon
  else
    Result := (B - A) <= Epsilon;
{$EXCESSPRECISION ON}
end;
procedure SinCosSingle(const Theta: Single; var Sin, Cos: Single);
var
{$IF SizeOf(Extended) > SizeOf(Double)}
  S, C: Extended;
{$ELSE}
  S, C: Double;
{$ENDIF}
begin
  S := System.Sin(Theta);
  C := System.Cos(Theta);

  Sin := S;
  Cos := C;
end;

{ TBitMapHelper }

class function TBitMapHelper.Create(AWidth, AHeight: integer): TBitMap;
begin

end;

{ TFormatSettingsHelper }

class function TFormatSettingsHelper.Create: TFormatSettings;
begin
  Result := TFormatSettings.Create('');
end;

class function TFormatSettingsHelper.Create(Locale: TLocaleID): TFormatSettings;
begin

end;

class function TFormatSettingsHelper.Create(const LocaleName: string
  ): TFormatSettings;
var
  Locale: LCID;
begin
  //if LocaleName <> '' then
  //begin
  //  if Win32MajorVersion >= 6 then
  //    // Windows Vista and later support a direct API call
  //    Locale := LocaleNameToLCID(PChar(AdjustLocaleName(LocaleName)), 0)
  //  else
  //    // Use TLanguages for older OS versions (slower)
  //    Locale := Languages.LocaleID[Languages.IndexOf(AdjustLocaleName(LocaleName))];
  //end
  //else
    Locale := GetThreadLocale;

  Result := Create(Locale);
end;

{ TPath }
class function TPath.Combine(const Path1, Path2: string): string;
begin
  Result := IncludeTrailingPathDelimiter(Path1) + Path2;
end;

class function TPath.Combine(const Path1, Path2, Path3: string): string;
begin
  Result := Combine(Combine(Path1, Path2), Path3);
end;

class function TPath.GetDirectoryName(const FileName: string): string;
begin
  Result := ExcludeTrailingPathDelimiter(ExtractFileDir(FileName));
end;

class function TPath.GetExtension(const FileName: string): string;
begin
  Result := ExtractFileExt(FileName);
end;

class function TPath.GetFileName(const FileName: string): string;
begin
  Result := ExtractFileName(FileName);
end;

class function TPath.GetFileNameWithoutExtension(const FileName: string): string;
begin
  Result := ChangeFileExt(ExtractFileName(FileName), '');
end;

class function TPath.GetFullPath(const Path: string): string;
begin
  Result := ExpandFileName(Path);
end;

class function TPath.GetTempPath: string;
begin
  Result := GetTempDir;
end;

class function TPath.GetTempFileName: string;
begin
  Result := SysUtils.GetTempFileName(GetTempDir, 'tmp');
end;

class function TPath.GetHomePath: string;
begin
  Result := SysUtils.GetEnvironmentVariable('HOME');

  {$IFDEF MSWINDOWS}
  if Result = '' then
    Result := SysUtils.GetEnvironmentVariable('USERPROFILE');
  {$ENDIF}
end;

class function TPath.GetDesktopPath: string;
begin
  Result := Combine(GetHomePath, 'Desktop');
end;

class function TPath.ChangeExtension(const Path, Extension: string): string;
begin
  Result := ChangeFileExt(Path, Extension);
end;

class function TPath.HasExtension(const Path: string): Boolean;
begin
  Result := ExtractFileExt(Path) <> '';
end;

class function TPath.IsPathRooted(const Path: string): Boolean;
begin
  Result := not IsRelativePath(Path);
end;

class function TPath.IsRelativePath(const Path: string): Boolean;
begin
    Result := Cod.Platform.Lazarus.IsRelativePath(Path);
end;

class function TPath.GetInvalidFileNameChars: TCharArray;
begin
  {$IFDEF MSWINDOWS}
  Result := ['<', '>', ':', '"', '/', '\', '|', '?', '*'];
  {$ELSE}
  Result := ['/'];
  {$ENDIF}
end;

class function TPath.GetInvalidPathChars: TCharArray;
begin
  {$IFDEF MSWINDOWS}
  Result := [#0, '<', '>', '"', '|', '?', '*'];
  {$ELSE}
  Result := [#0];
  {$ENDIF}
end;

class function TPath.GetRandomFileName: string;
begin
  Result := SysUtils.GetTempFileName('', '');
  DeleteFile(PChar(Result));
  Result := ExtractFileName(Result);
end;

class function TPath.GetDirectorySeparatorChar: Char;
begin
  {$IFDEF MSWINDOWS}
  Result := '\';
  {$ELSE}
  Result := '/';
  {$ENDIF}
end;

class function TPath.GetAltDirectorySeparatorChar: Char;
begin
  Result := '/';
end;

{ TDirectory }

class function TDirectory.Exists(const Path: string): Boolean;
begin
  Result := DirectoryExists(Path);
end;

class function TDirectory.CreateDirectory(const Path: string): Boolean;
begin
  Result := ForceDirectories(Path);
end;

class function TDirectory.GetCurrentDirectory: string;
begin
  Result := GetCurrentDir;
end;

class function TDirectory.SetCurrentDirectory(const Path: string): Boolean;
begin
  Result := SetCurrentDir(Path);
end;

class function TDirectory.GetParent(const Path: string): string;
begin
  Result := ExtractFileDir(ExcludeTrailingPathDelimiter(Path));
end;

class procedure TDirectory.Copy(const SourceDirName, DestDirName: string);
begin
  if not CopyDirTree(SourceDirName, DestDirName, [TCopyFileFlag.cffCreateDestDirectory, TCopyFileFlag.cffOverwriteFile, TCopyFileFlag.cffPreserveTime]) then
    raise EInOutError.CreateFmt(
      'Could not copy directory "%s" to "%s".',
      [SourceDirName, DestDirName]
    );
end;

class procedure TDirectory.Move(const SourceDirName, DestDirName: string);
begin
  if not RenameFile(SourceDirName, DestDirName) then
    raise EInOutError.CreateFmt(
      'Could not move directory "%s" to "%s".',
      [SourceDirName, DestDirName]
    );
end;

class procedure TDirectory.Delete(const Path: string);
begin
  if not RemoveDir(Path) then
    raise EInOutError.CreateFmt('Could not delete directory "%s".', [Path]);
end;

class procedure TDirectory.Delete(const Path: string;
  const Recursive: Boolean);
begin
  if Recursive then
  begin
    if not DeleteDirectory(Path, False) then
      raise EInOutError.CreateFmt('Could not delete directory "%s".', [Path]);
  end
  else
    Delete(Path);
end;

class function TDirectory.GetFiles(const Path: string;
  const SearchPattern: string; const SearchOption: TSearchOption
  ): TStringDynArray;
var
   List: TStringList;
begin
  List := FindAllFiles(Path, SearchPattern, SearchOption = TSearchOption.soAllDirectories);
  try
    Result := List.ToStringArray;
  finally
    List.Free;
  end;
end;

class function TDirectory.GetDirectories(const Path: string;
  const SearchOption: TSearchOption
  ): TStringDynArray;
var
   List: TStringList;
begin
  List := FindAllDirectories(Path, SearchOption = TSearchOption.soAllDirectories);
  try
    Result := List.ToStringArray;
  finally
    List.Free;
  end;
end;

{ TFile }

class function TFile.Create(const Path: string): TFileStream;
begin
  Result := TFileStream.Create(Path, Classes.fmCreate);
end;

class function TFile.Create(const Path: string;
  const BufferSize: Integer): TFileStream;
begin
  Result := TFileStream.Create(Path, Classes.fmCreate, BufferSize);
end;

class procedure TFile.AppendAllText(const Path, Contents: string);
var
  F: TextFile;
begin
  AssignFile(F, Path);
  if FileExists(Path) then
    Append(F)
  else
    Rewrite(F);

  try
    Write(F, Contents);
  finally
    CloseFile(F);
  end;
end;

class procedure TFile.Copy(const SourceFileName, DestFileName: string);
begin
  if not FileUtil.CopyFile(SourceFileName, DestFileName) then
    raise EInOutError.CreateFmt(
      'Could not copy file "%s" to "%s".',
      [SourceFileName, DestFileName]
    );
end;

class procedure TFile.Copy(const SourceFileName, DestFileName: string;
  const Overwrite: Boolean);
begin
  if not Overwrite and FileExists(DestFileName) then
    raise EInOutError.CreateFmt(
      'File "%s" already exists.',
      [DestFileName]
    );

  if not FileUtil.CopyFile(SourceFileName, DestFileName, Overwrite) then
    raise EInOutError.CreateFmt(
      'Could not copy file "%s" to "%s".',
      [SourceFileName, DestFileName]
    );
end;

class function TFile.CreateSymLink(const Link, Target: string): Boolean;
begin
  Result := false;
end;

class procedure TFile.Delete(const Path: string);
begin
  if not SysUtils.DeleteFile(Path) then
    raise EInOutError.CreateFmt(
      'Could not delete file "%s".',
      [Path]
    );
end;

class function TFile.Exists(const Path: string;
  FollowLink: Boolean): Boolean;
begin
  Result := FileExists(Path);
end;

class function TFile.GetSize(const Path: string): Int64;
begin
  Result := filesize(Path);
end;

class procedure TFile.Move(SourceFileName, DestFileName: string);
begin
  if not RenameFile(SourceFileName, DestFileName) then
    raise EInOutError.CreateFmt(
      'Could not move file "%s" to "%s".',
      [SourceFileName, DestFileName]
    );
end;

class function TFile.Open(const Path: string;
  const Mode: word): TFileStream;
begin
  Result := TFileStream.Create(Path, Mode);
end;

class function TFile.GetCreationTime(const Path: string): TDateTime;
var
  H: THandle;
  CreationTime, LastAccessTime, LastWriteTime: TFileTime;
  ST: TSystemTime;
begin
  Result := 0;

  H := FileOpen(Path, fmOpenRead or fmShareDenyNone);
  if H = THandle(-1) then
    Exit;

  try
    if not Windows.GetFileTime(
      H,
      @CreationTime,
      @LastAccessTime,
      @LastWriteTime
    ) then
      Exit;

    if not FileTimeToSystemTime(CreationTime, ST) then
      Exit;

    Result := SystemTimeToDateTime(ST);
  finally
    FileClose(H);
  end;
end;

class function TFile.GetLastAccessTime(const Path: string): TDateTime;
var
  H: THandle;
  CreationTime, LastAccessTime, LastWriteTime: TFileTime;
  ST: TSystemTime;
begin
  Result := 0;

  H := FileOpen(Path, fmOpenRead or fmShareDenyNone);
  if H = THandle(-1) then
    Exit;

  try
    if not Windows.GetFileTime(
      H,
      @CreationTime,
      @LastAccessTime,
      @LastWriteTime
    ) then
      Exit;

    if not FileTimeToSystemTime(LastAccessTime, ST) then
      Exit;

    Result := SystemTimeToDateTime(ST);
  finally
    FileClose(H);
  end;
end;

class function TFile.GetLastWriteTime(const Path: string): TDateTime;
var
  Age: LongInt;
begin
  Age := FileAge(Path);

  if Age = -1 then
    Exit(0);

  Result := FileDateToDateTime(Age);
end;

class procedure TFile.SetCreationTime(const Path: string;
  const CreationTime: TDateTime);
var
  H: THandle;
  FT: TFileTime;
  ST: TSystemTime;
begin
  H := FileOpen(Path, fmOpenReadWrite or fmShareDenyNone);
  if H = THandle(-1) then
    raise EInOutError.CreateFmt('Could not open file "%s".', [Path]);

  try
    DateTimeToSystemTime(CreationTime, ST);
    if not SystemTimeToFileTime(ST, FT) then
      raise EInOutError.CreateFmt(
        'Could not convert creation time for "%s".', [Path]);

    if not Windows.SetFileTime(H, @FT, nil, nil) then
      raise EInOutError.CreateFmt(
        'Could not set creation time for "%s".', [Path]);
  finally
    FileClose(H);
  end;
end;

class procedure TFile.SetLastAccessTime(const Path: string;
  const LastAccessTime: TDateTime);
var
  H: THandle;
  FT: TFileTime;
  ST: TSystemTime;
begin
  H := FileOpen(Path, fmOpenReadWrite or fmShareDenyNone);
  if H = THandle(-1) then
    raise EInOutError.CreateFmt('Could not open file "%s".', [Path]);

  try
    DateTimeToSystemTime(LastAccessTime, ST);
    if not SystemTimeToFileTime(ST, FT) then
      raise EInOutError.CreateFmt(
        'Could not convert last access time for "%s".', [Path]);

    if not Windows.SetFileTime(H, nil, @FT, nil) then
      raise EInOutError.CreateFmt(
        'Could not set last access time for "%s".', [Path]);
  finally
    FileClose(H);
  end;
end;

class procedure TFile.SetLastWriteTime(const Path: string;
  const LastWriteTime: TDateTime);
var
  H: THandle;
  FT: TFileTime;
  ST: TSystemTime;
begin
  H := FileOpen(Path, fmOpenReadWrite or fmShareDenyNone);
  if H = THandle(-1) then
    raise EInOutError.CreateFmt('Could not open file "%s".', [Path]);

  try
    DateTimeToSystemTime(LastWriteTime, ST);
    if not SystemTimeToFileTime(ST, FT) then
      raise EInOutError.CreateFmt(
        'Could not convert last write time for "%s".', [Path]);

    if not Windows.SetFileTime(H, nil, nil, @FT) then
      raise EInOutError.CreateFmt(
        'Could not set last write time for "%s".', [Path]);
  finally
    FileClose(H);
  end;
end;

class function TFile.OpenRead(const Path: string): TFileStream;
begin
  Result := TFileStream.Create(Path, fmOpenRead or fmShareDenyWrite);
end;

class function TFile.OpenWrite(const Path: string): TFileStream;
begin
  Result := TFileStream.Create(Path, fmOpenWrite or fmShareDenyWrite);
end;

class function TFile.ReadAllBytes(const Path: string): TBytes;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(Path, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(Result, Stream.Size);
    if Length(Result) > 0 then
      Stream.ReadBuffer(Result[0], Length(Result));
  finally
    Stream.Free;
  end;
end;

class function TFile.ReadAllLines(const Path: string): TStringDynArray;
var
  F: TextFile;
  Line: string;
  I: Integer;
begin
  SetLength(Result, 0);

  AssignFile(F, Path);
  Reset(F);
  try
    while not EOF(F) do
    begin
      ReadLn(F, Line);

      I := Length(Result);
      SetLength(Result, I + 1);
      Result[I] := Line;
    end;
  finally
    CloseFile(F);
  end;
end;

class function TFile.ReadAllText(const Path: string): string;
var
  F: TextFile;
  Line: string;
begin
  Result := '';

  AssignFile(F, Path);
  Reset(F);
  try
    while not EOF(F) do
    begin
      ReadLn(F, Line);

      if Result <> '' then
        Result := Result + LineEnding;

      Result := Result + Line;
    end;
  finally
    CloseFile(F);
  end;
end;

class procedure TFile.WriteAllBytes(const Path: string;
  const Bytes: TBytes);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(Path, Classes.fmCreate);
  try
    if Length(Bytes) > 0 then
      Stream.WriteBuffer(Bytes[0], Length(Bytes));
  finally
    Stream.Free;
  end;
end;

class procedure TFile.WriteAllLines(const Path: string;
  const Contents: TStringDynArray);
var
  F: TextFile;
  I: Integer;
begin
  AssignFile(F, Path);
  Rewrite(F);
  try
    for I := 0 to Length(Contents) - 1 do
      WriteLn(F, Contents[I]);
  finally
    CloseFile(F);
  end;
end;

class procedure TFile.WriteAllText(const Path, Contents: string);
var
  F: TextFile;
begin
  AssignFile(F, Path);
  Rewrite(F);
  try
    Write(F, Contents);
  finally
    CloseFile(F);
  end;
end;



{ TPointFHelper }

procedure TPointFHelper.Offset(const ADeltaX, ADeltaY: Single);
begin
  Self.Offset(TPointF.Create(ADeltaX, ADeltaY));
end;

function TPointFHelper.EqualsTo(const Point: TPointF; const Epsilon: Single
  ): Boolean;
begin
    Result := SameValue(X, Point.X, Epsilon) and SameValue(Y, Point.Y, Epsilon);
end;

function TPointFHelper.Normalize: TPointF;
var
  Len: Single;
begin
  Len := Sqrt(Sqr(X) + Sqr(Y));

  if (Len <> 0.0) then
  begin
    Result.X := X / Len;
    Result.Y := Y / Len;
  end
  else
    Result := Self;
end;

function TPointFHelper.Rotate(const AAngle: Single): TPointF;
var
  Sine, Cosine: Single;
begin
  SinCosSingle(AAngle, Sine, Cosine);
  Result.X := X * Cosine - Y * Sine;
  Result.Y := X * Sine + Y * Cosine;
end;

function TPointFHelper.Reflect(const APoint: TPointF): TPointF;
begin
  Result := Self + APoint * (-2 * Self.DotProduct(APoint));
end;

function TPointFHelper.MidPoint(const APoint: TPointF): TPointF;
begin
  Result.X := (Self.X + APoint.X) / 2;
  Result.Y := (Self.Y + APoint.Y) / 2;
end;

function TPointFHelper.AngleCosine(const APoint: TPointF): Single;
begin
  Result := Self.Length * APoint.Length;

  if Abs(Result) > Epsilon then
    Result := Self.DotProduct(APoint) / Result
  else
    Result := Self.DotProduct(APoint) / Epsilon;

  Result := Max(Min(Result, 1), -1);
end;

function TPointFHelper.Angle(const APoint: TPointF): Single;
begin
  Result := Arctan2(Self.Y - APoint.Y, Self.X - APoint.X);
end;



function IsRelativePath(const Path: string): Boolean;
var
  L: Integer;
begin
  L := Length(Path);
  Result := ((L = 0) or ((L > 0) and (Path[Low(string)] <> PathDelim)))
    {$IFDEF MSWINDOWS} and ( (L <= 1) or (Path[Low(string) + 1] <> ':') ); {$ENDIF MSWINDOWS};
end;



function Min(const A, B: Single): Single;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function Max(const A, B: Single): Single;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;




function EqualRect(const R1, R2: TRectF): Boolean;
begin
  Result := (R1.Left = R2.Left) and (R1.Right = R2.Right) and
    (R1.Top = R2.Top) and (R1.Bottom = R2.Bottom);
end;

function RectF(Left, Top, Right, Bottom: Single): TRectF;
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Bottom := Bottom;
  Result.Right := Right;
end;

function NormalizeRectF(const Pts: array of TPointF): TRectF;
var
  Pt: TPointF;
begin
  Result.Left := $F000;
  Result.Top := $F000;
  Result.Right := -$F000;
  Result.Bottom := -$F000;
  for Pt in Pts do
  begin
    if Pt.X < Result.Left then
      Result.Left := Pt.X;
    if Pt.Y < Result.Top then
      Result.Top := Pt.Y;
    if Pt.X > Result.Right then
      Result.Right := Pt.X;
    if Pt.Y > Result.Bottom then
      Result.Bottom := Pt.Y;
  end;
end;

function NormalizeRect(const ARect: TRectF): TRectF;
begin
  Result := NormalizeRectF([TPointF.Create(ARect.Left, ARect.Top), TPointF.Create(ARect.Right, ARect.Top),
    TPointF.Create(ARect.Right, ARect.Bottom), TPointF.Create(ARect.Left, ARect.Bottom)]);
end;

function RectWidth(const Rect: TRect): Integer;
begin
  Result := Rect.Right - Rect.Left;
end;

function RectHeight(const Rect: TRect): Integer;
begin
  Result := Rect.Bottom - Rect.Top;
end;

function RectWidth(const Rect: TRectF): Single;
begin
  Result := Rect.Right - Rect.Left;
end;

function RectHeight(const Rect: TRectF): Single;
begin
  Result := Rect.Bottom - Rect.Top;
end;

function RectCenter(var R: TRect; const Bounds: TRect): TRect;
begin
  OffsetRect(R, -R.Left, -R.Top);
  OffsetRect(R, (RectWidth(Bounds) - RectWidth(R)) div 2, (RectHeight(Bounds) - RectHeight(R)) div 2);
  OffsetRect(R, Bounds.Left, Bounds.Top);
  Result := R;
end;

function RectCenter(var R: TRectF; const Bounds: TRectF): TRectF;
begin
  OffsetRect(R, -R.Left, -R.Top);
  OffsetRect(R, (RectWidth(Bounds)/2 - RectWidth(R)/2), (RectHeight(Bounds)/2 - RectHeight(R)/2));
  OffsetRect(R, Bounds.Left, Bounds.Top);
  Result := R;
end;

function PointF(X, Y: Single): TPointF;
begin
  Result.X := X;
  Result.Y := Y;
end;

function MinPoint(const P1, P2: TPointF): TPointF;
begin
  Result := P1;
  if (P2.Y < P1.Y) or ((P2.Y = P1.Y) and (P2.X < P1.X)) then
    Result := P2;
end;

function MinPoint(const P1, P2: TPoint): TPoint;
begin
  Result := P1;
  if (P2.Y < P1.Y) or ((P2.Y = P1.Y) and (P2.X < P1.X)) then
    Result := P2;
end;

function ScalePoint(const P: TPointF; dX, dY: Single): TPointF;
begin
{$EXCESSPRECISION OFF}
  Result.X := P.X * dX;
  Result.Y := P.Y * dY;
{$EXCESSPRECISION ON}
end;

function ScalePoint(const P: TPoint; dX, dY: Single): TPoint;
begin
  Result.X := Round(P.X * dX);
  Result.Y := Round(P.Y * dY);
end;

function PtInRect(const Rect: TRectF; const P: TPointF): Boolean;
begin
  Result := (P.X >= Rect.Left) and (P.X < Rect.Right) and (P.Y >= Rect.Top)
    and (P.Y < Rect.Bottom);
end;

function IntersectRect(const Rect1, Rect2: TRectF): Boolean;
begin
  Result := (Rect1.Left < Rect2.Right)
        and (Rect1.Right > Rect2.Left)
        and (Rect1.Top < Rect2.Bottom)
        and (Rect1.Bottom > Rect2.Top);
end;

function IntersectRect(out Rect: TRectF; const R1, R2: TRectF): Boolean;
var
  tmpRect: TRectF;
begin
  tmpRect := R1;
  if R2.Left > R1.Left then tmpRect.Left := R2.Left;
  if R2.Top > R1.Top then tmpRect.Top := R2.Top;
  if R2.Right < R1.Right then tmpRect.Right := R2.Right;
  if R2.Bottom < R1.Bottom then tmpRect.Bottom := R2.Bottom;
  Result := not IsRectEmpty(tmpRect);
  if not Result then FillChar(tmpRect, SizeOf(Rect), 0);
  Rect := tmpRect;
end;

function UnionRect(out Rect: TRectF; const R1, R2: TRectF): Boolean;
var
  tmpRect: TRectF;
begin
  tmpRect := R1;
  if not ((R2.Right < R2.Left) or (R2.Bottom < R2.Top)) then
  begin
    if R2.Left < R1.Left then tmpRect.Left := R2.Left;
    if R2.Top < R1.Top then tmpRect.Top := R2.Top;
    if R2.Right > R1.Right then tmpRect.Right := R2.Right;
    if R2.Bottom > R1.Bottom then tmpRect.Bottom := R2.Bottom;
  end;
  Result := not IsRectEmpty(tmpRect);
  if not Result then FillChar(tmpRect, SizeOf(Rect), 0);
  Rect := tmpRect;
end;

function IsRectEmpty(const Rect: TRectF): Boolean;
begin
  Result := (Rect.Right <= Rect.Left) or (Rect.Bottom <= Rect.Top);
end;

function OffsetRect(var R: TRectF; DX, DY: Single): Boolean;
begin
{$EXCESSPRECISION OFF}
  if @R <> nil then // Test to increase compatiblity with Windows
  begin
    R.Left := R.Left + DX;
    R.Right := R.Right + DX;
    R.Top := R.Top + DY;
    R.Bottom := R.Bottom + DY;
    Result := True;
  end
  else
    Result := False;
{$EXCESSPRECISION ON}
end;

procedure MultiplyRect(var R: TRectF; const DX, DY: Single);
begin
  R.Left := R.Left * dX;
  R.Right := R.Right * dX;
  R.Top := R.Top * dY;
  R.Bottom := R.Bottom * dY;
end;

procedure InflateRect(var R: TRectF; const DX, DY: Single);
begin
{$EXCESSPRECISION OFF}
  R.Left := R.Left - DX;
  R.Right := R.Right + DX;
  R.Top := R.Top - DY;
  R.Bottom := R.Bottom + DY;
{$EXCESSPRECISION ON}
end;

function IntersectRectF(out Rect: TRectF; const R1, R2: TRectF): Boolean;
var
  tmpRect: TRectF;
begin
  tmpRect := R1;
  if R2.Left > R1.Left then tmpRect.Left := R2.Left;
  if R2.Top > R1.Top then tmpRect.Top := R2.Top;
  if R2.Right < R1.Right then tmpRect.Right := R2.Right;
  if R2.Bottom < R1.Bottom then tmpRect.Bottom := R2.Bottom;
  Result := not tmpRect.IsEmpty;
  if not Result then
  begin
    tmpRect.Top := 0.0;
    tmpRect.Bottom := 0.0;
    tmpRect.Left := 0.0;
    tmpRect.Right := 0.0;
  end;
  Rect := tmpRect;
end;

function UnionRectF(out Rect: TRectF; const R1, R2: TRectF): Boolean;
var
  tmpRect: TRectF;
begin
  tmpRect := R1;
  if not ((R2.Right < R2.Left) or (R2.Bottom < R2.Top)) then
  begin
    if R2.Left < R1.Left then tmpRect.Left := R2.Left;
    if R2.Top < R1.Top then tmpRect.Top := R2.Top;
    if R2.Right > R1.Right then tmpRect.Right := R2.Right;
    if R2.Bottom > R1.Bottom then tmpRect.Bottom := R2.Bottom;
  end;
  Result := not tmpRect.IsEmpty;
  if not Result then
  begin
    tmpRect.Top :=0.0;
    tmpRect.Bottom := 0.0;
    tmpRect.Left := 0.0;
    tmpRect.Right := 0.0;
  end;
  Rect := tmpRect;
end;



{ TSizeF }
function TSizeF.Add(const Point: TSizeF): TSizeF;
begin
{$EXCESSPRECISION OFF}
  Result.cx := cx + Point.cx;
  Result.cy := cy + Point.cy;
{$EXCESSPRECISION ON}
end;

class operator TSizeF.Add(const Lhs, Rhs: TSizeF): TSizeF;
begin
{$EXCESSPRECISION OFF}
  Result.cx := Lhs.cx + Rhs.cx;
  Result.cy := Lhs.cy + Rhs.cy;
{$EXCESSPRECISION ON}
end;

constructor TSizeF.Create(const X, Y: Single);
begin
  cx := X;
  cy := Y;
end;

constructor TSizeF.Create(P: TSizeF);
begin
  cx := P.cx;
  cy := P.cy;
end;

function TSizeF.Distance(const P2: TSizeF): Double;
begin
  Result := Sqrt(Sqr(Self.cx - P2.cx) + Sqr(Self.cy - P2.cy));
end;

class operator TSizeF.Implicit(const Point: TPointF): TSizeF;
begin
  Result.cx := Point.X;
  Result.cy := Point.Y;
end;

class operator TSizeF.Implicit(const Size: TSizeF): TPointF;
begin
  Result.X := Size.cx;
  Result.Y := Size.cy;
end;

function TSizeF.IsZero: Boolean;
begin
  Result := SameValue(cx, 0.0) and SameValue(cy, 0.0);
end;

class operator TSizeF.Equal(const Lhs, Rhs: TSizeF): Boolean;
begin
  Result := SameValue(Lhs.cx, Rhs.cx) and SameValue(Lhs.cy, Rhs.cy);
end;

class operator TSizeF.NotEqual(const Lhs, Rhs: TSizeF): Boolean;
begin
  Result := not (Lhs = Rhs);
end;

function TSizeF.Subtract(const Point: TSizeF): TSizeF;
begin
{$EXCESSPRECISION OFF}
  Result.cx := cx - Point.cx;
  Result.cy := cy - Point.cy;
{$EXCESSPRECISION ON}
end;

function TSizeF.SwapDimensions: TSizeF;
begin
  Result := TSizeF.Create(Height, Width);
end;

class operator TSizeF.Subtract(const Lhs, Rhs: TSizeF): TSizeF;
begin
{$EXCESSPRECISION OFF}
  Result.cx := Lhs.cx - Rhs.cx;
  Result.cy := Lhs.cy - Rhs.cy;
{$EXCESSPRECISION ON}
end;

function TSizeF.Ceiling: TSize;
begin
  Result.cx := Ceil(cx);
  Result.cy := Ceil(cy);
end;

function TSizeF.Round: TSize;
begin
  Result.cx := Trunc(cx + 0.5);
  Result.cy := Trunc(cy + 0.5);
end;

function TSizeF.Truncate: TSize;
begin
  Result.cx := Trunc(cx);
  Result.cy := Trunc(cy);
end;

class operator TSizeF.Implicit(const Size: TSize): TSizeF;
begin
  Result.cx := Size.cx;
  Result.cy := Size.cy;
end;

{ TRectFHelper }

function TRectFHelper.GetSize: TSizeF;
begin
  Result.cx := Width;
  Result.cy := Height;
end;

procedure TRectFHelper.SetSize(const Value: TSizeF);
begin
  Width := Value.cx;
  Height := Value.cy;
end;

function TRectFHelper.GetLocation: TPointF;
begin
  Result := TopLeft;
end;

constructor TRectFHelper.Create(const Origin: TPointF);
begin
  TopLeft := Origin;
  BottomRight := Origin;
end;

constructor TRectFHelper.Create(const Origin: TPointF; const Width,
  Height: Single);
begin
  Self.TopLeft := Origin;
  Self.Width := Width;
  Self.Height := Height;
end;

constructor TRectFHelper.Create(const Left, Top, Right, Bottom: Single);
begin
  Self.Left := Left; Self.Top := Top;
  Self.Right := Right; Self.Bottom := Bottom;
end;

constructor TRectFHelper.Create(const P1, P2: TPointF; Normalize: Boolean);
begin
  Self.TopLeft := P1;
  Self.BottomRight := P2;
  if Normalize then NormalizeRect;
end;

constructor TRectFHelper.Create(const R: TRectF; Normalize: Boolean);
begin
  Self := R;
  if Normalize then NormalizeRect;
end;

constructor TRectFHelper.Create(const R: TRect; Normalize: Boolean);
begin
  Self.Left := R.Left;
  Self.Top  := R.Top;
  Self.Right := R.Right;
  Self.Bottom := R.Bottom;
  if Normalize then NormalizeRect;
end;

class function TRectFHelper.Empty: TRectF;
begin
  Result := TRectF.Create(0,0,0,0);
end;

procedure TRectFHelper.NormalizeRect;
var
  temp: Single;
begin
  if Top > Bottom then
  begin
    temp := Top;
    Top := Bottom;
    Bottom := temp;
  end;
  if Left > Right then
  begin
    temp := Left;
    Left := Right;
    Right := temp;
  end
end;

function TRectFHelper.IsEmpty: Boolean;
begin
  Result := (Right <= Left) or (Bottom <= Top);
end;

function TRectFHelper.Contains(const Pt: TPointF): Boolean;
begin
  Result := (Pt.X >= Self.Left)
        and (Pt.X < Self.Right)
        and (Pt.Y >= Self.Top)
        and (Pt.Y < Self.Bottom);
end;

function TRectFHelper.Contains(const R: TRectF): Boolean;
begin
  Result := (Self.Left <= R.Left)
        and (Self.Right >= R.Right)
        and (Self.Top <= R.Top)
        and (Self.Bottom >= R.Bottom);
end;

function TRectFHelper.IntersectsWith(const R: TRectF): Boolean;
begin
  Result := (Self.Left < R.Right)
        and (Self.Right > R.Left)
        and (Self.Top < R.Bottom)
        and (Self.Bottom > R.Top);
end;

class function TRectFHelper.Intersect(const R1: TRectF; const R2: TRectF
  ): TRectF;
begin
  IntersectRectF(Result, R1, R2);
end;

procedure TRectFHelper.Intersect(const R: TRectF);
begin
  Self := Intersect(Self, R);
end;

class function TRectFHelper.Union(const R1: TRectF; const R2: TRectF): TRectF;
begin
  UnionRectF(Result, R1, R2);
end;

procedure TRectFHelper.Union(const R: TRectF);
begin
  Self := TRectF.Union(Self, R);
end;

class function TRectFHelper.Union(const Points: array of TPointF): TRectF;
var
  I: Integer;
  TLCorner, BRCorner: TPointF;
begin
  if Length(Points) > 0 then
  begin
    TLCorner := Points[Low(Points)];
    BRCorner := Points[Low(Points)];

    if Length(Points) > 1 then
    begin
      for I := Low(Points) + 1 to High(Points) do
      begin
        if Points[I].X < TLCorner.X then TLCorner.X := Points[I].X;
        if Points[I].X > BRCorner.X then BRCorner.X := Points[I].X;
        if Points[I].Y < TLCorner.Y then TLCorner.Y := Points[I].Y;
        if Points[I].Y > BRCorner.Y then BRCorner.Y := Points[I].Y;
      end;
    end;

    Result := TRectF.Create(TLCorner, BRCorner);
  end
  else begin
    Result := TRectF.Empty;
  end;
end;

procedure TRectFHelper.Offset(const DX, DY: Single);
begin
  TopLeft.Offset(DX, DY);
  BottomRight.Offset(DX, DY);
end;

procedure TRectFHelper.Offset(const Point: TPointF);
begin
  TopLeft.Offset(Point);
  BottomRight.Offset(Point);
end;

procedure TRectFHelper.SetLocation(const X, Y: Single);
begin
  {$EXCESSPRECISION OFF}
    Offset(X - Left, Y - Top);
  {$EXCESSPRECISION ON}
end;

procedure TRectFHelper.SetLocation(const Point: TPointF);
begin
  {$EXCESSPRECISION OFF}
    Offset(Point.X - Left, Point.Y - Top);
  {$EXCESSPRECISION ON}
end;

procedure TRectFHelper.Inflate(const DX, DY: Single);
begin
  {$EXCESSPRECISION OFF}
    TopLeft.Offset(-DX, -DY);
    BottomRight.Offset(DX, DY);
  {$EXCESSPRECISION ON}
end;

procedure TRectFHelper.Inflate(const DL, DT, DR, DB: Single);
begin
  {$EXCESSPRECISION OFF}
    TopLeft.Offset(-DL, -DT);
    BottomRight.Offset(DR, DB);
  {$EXCESSPRECISION ON}
end;

function TRectFHelper.CenterPoint: TPointF;
begin
  {$EXCESSPRECISION OFF}
    Result.X := (Right - Left)/2.0 + Left;
    Result.Y := (Bottom - Top)/2.0 + Top;
  {$EXCESSPRECISION ON}
end;

function TRectFHelper.Ceiling: TRect;
begin
  Result.TopLeft := TopLeft.Ceiling;
  Result.BottomRight := BottomRight.Ceiling;
end;

function TRectFHelper.Truncate: TRect;
begin
  Result.TopLeft := TopLeft.Truncate;
  Result.BottomRight := BottomRight.Truncate;
end;

function TRectFHelper.Round: TRect;
begin
  Result.TopLeft := TopLeft.Round;
  Result.BottomRight := BottomRight.Round;
end;

function TRectFHelper.EqualsTo(const R: TRectF; const Epsilon: Single): Boolean;
begin
  Result := TopLeft.EqualsTo(R.TopLeft, Epsilon) and BottomRight.EqualsTo(R.BottomRight, Epsilon);
end;



constructor TQueue<T>.Create;
begin
  inherited Create;
  FHead := 0;
  FTail := 0;
end;

function TQueue<T>.GetCount: Integer;
begin
  Result := FTail - FHead;
end;

procedure TQueue<T>.Enqueue(const Item: T);
var
  I: Integer;
begin
  if FTail >= Length(FItems) then
  begin
    if FHead > 0 then
    begin
      // Compact the queue
      for I := FHead to FTail - 1 do
        FItems[I - FHead] := FItems[I];

      FTail := FTail - FHead;
      FHead := 0;
    end;

    if FTail >= Length(FItems) then
      SetLength(FItems, Length(FItems) * 2 + 4);
  end;

  FItems[FTail] := Item;
  Inc(FTail);
end;

function TQueue<T>.Dequeue: T;
begin
  if FHead >= FTail then
    raise Exception.Create('Queue is empty.');

  Result := FItems[FHead];
  Inc(FHead);

  // Reset when completely consumed
  if FHead = FTail then
  begin
    FHead := 0;
    FTail := 0;
  end;
end;

{$ENDIF}
end.
