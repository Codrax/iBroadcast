unit PopupPlayForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  SpectrumVis3D, Cod.Audio, MainUI;

type

  { TPopupPlay }

  TPopupPlay = class(TForm)
    Button1: TButton;
    Music_Artist: TLabel;
    Music_Artwork: TImage;
    Music_Name: TLabel;
    Music_Next: TButton;
    Music_Play: TButton;
    Music_Prev: TButton;
    Music_Time: TLabel;
    Panel7: TPanel;
    Visualisation_Player: TPaintBox;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ButtonsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Panel7Click(Sender: TObject);
    procedure Visualisation_PlayerPaint(Sender: TObject);
  private
    // Visualisations
    FSpectrumVisualisation: TSpectrum;

  public

  end;

var
  PopupPlay: TPopupPlay;

implementation

{$R *.lfm}

{ TPopupPlay }

procedure TPopupPlay.FormCreate(Sender: TObject);
begin
  // Spectrum
  FSpectrumVisualisation := TSpectrum.Create(round(Visualisation_Player.Width * ScaleFactor), round(Visualisation_Player.Height * ScaleFactor));
  FSpectrumVisualisation.Height := Visualisation_Player.Height - 20;
  FSpectrumVisualisation.Peak := clMenuText;
  FSpectrumVisualisation.Pen:= RGBToColor(255, 105, 180);
  FSpectrumVisualisation.BackColor := clWindow;
end;

procedure TPopupPlay.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TPopupPlay.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
  PopupPlay := nil;

  // Show Main
  Main.Show;
end;

procedure TPopupPlay.ButtonsClick(Sender: TObject);
var
  C: TControl;
begin
  C := Main.Panel5.FindChildControl(TComponent(Sender).Name);

  if C <> nil then
    C.OnClick(C);
end;

procedure TPopupPlay.FormDestroy(Sender: TObject);
begin
end;

procedure TPopupPlay.FormShow(Sender: TObject);
begin
  if not Visualisation_Player.Visible then
    ClientHeight:=Panel7.BoundsRect.Bottom;
end;

procedure TPopupPlay.Panel7Click(Sender: TObject);
begin

end;

procedure TPopupPlay.Visualisation_PlayerPaint(Sender: TObject);
var
  Style: TTextStyle;
  ARect: TRect;
begin
  if (Player = nil) or (not Player.IsFileOpen) or (Player.PlayStatus <> TPlayStatus.Playing) then begin
    with TPaintBox(Sender).Canvas do begin
      ARect := TPaintBox(Sender).ClientRect;

      Style.Alignment:=taCenter;
      Style.Layout:=tlCenter;
      Style.Wordbreak := true;

      with TPaintBox(Sender).Canvas do begin
        Font.Assign(Self.Font);
        TextRect(ARect, 0,0, 'Play to show visualistions.', Style);
      end;
    end;
    Exit;
  end;

  FSpectrumVisualisation.Draw(TPaintbox(Sender).Canvas, CurrentVisualisationData, 0, -10);
end;

end.

