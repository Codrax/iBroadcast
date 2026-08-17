{***********************************************************}
{           Codrut Easter Eggs Internal Library             }
{                                                           }
{                     Codename Meaw                         }
{                                                           }
{***********************************************************}

{$SCOPEDENUMS ON}

unit Cod.Special.EasterEggs;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Variants, Vcl.Clipbrd, IOUtils, Winapi.ShellAPI, DateUtils,
  Winapi.MMSystem, System.Zip, Cod.Windows;

type
  TBeepType = (Information, Error, Confirmation, Warning);

// Christmas
function IsChristmasTime: boolean;

implementation

function IsChristmasTime: Boolean;
begin
  const ADateTime = Now;
  Result := MonthOf(ADateTime) = 12;
end;

end.