unit UnitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Menus, GdipApi, GdipClass;

type
  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
  public
    procedure GPDrawHorloge(const H,M,S,Z : word);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


const
  // valeur constantes précalculées
  DTR = pi/180;
  DTM = 360/60;
  STM = 1/60;
  HTM = 5/60;

type
  TSinCos = record
    Big   : TGPPointF;
    Small : TGPPointF;
  end;

var
  // tableau de precalculs des Sinus Cosinus
  PCS : array[0..59] of TSinCos;

  // Couleur predefinie
  GroundColor,
  PieColor,
  TextColor   : ARGB;

  // Coordonnées Texte
  CPtHour,
  CPtMin,
  CPtSec,
  CPtMSec : TGPPointF;

procedure SinCos(const Theta: Extended; var Sin, Cos: Extended);
  // imported from unit Math.Pas
asm
  FLD     Theta
  FSINCOS
  FSTP    tbyte ptr [edx]    // Cos
  FSTP    tbyte ptr [eax]    // Sin
  FWAIT
end;

procedure TForm1.FormCreate(Sender: TObject);
var N : integer;
    S,C : extended;
begin
  // Evite le scintillement
  DoubleBuffered := true;

  // Precalculs Sin Cos
  for N := 0 to 59 do
  begin
    // on decale de -90° pour avoir le 0 en haut
    SinCos( DTR * (round((N * DTM)-90) mod 360), S, C);
    PCS[N].Big.X   := 22 * C; // grand rayon
    PCS[N].Big.Y   := 22 * S;
    PCS[N].Small.X := 18 * C; // petit rayon
    PCS[N].Small.Y := 18 * S;
  end;

  // Autres parametres
  // Couleur de fond
  //GroundColor := ARGBMake(255,136,152,124);
   GroundColor := aclBtnFace; {windows color theme}

  // Couleur des "aiguilles"
  //PieColor    := ARGBMake(128,0,0,0);
   PieColor := aclSkyBlue; {windows color theme}

  // Couleur du texte
  //TextColor   := aclBlack;
  TextColor := aclBtnText; {windows color theme}

  // Position du texte des cadrans
  CPtHour := GPPointFMake( 16.0, 21.0);
  CPtMin  := GPPointFMake( 64.0, 21.0);
  CPtSec  := GPPointFMake(112.0, 21.0);
  CPtMSec := GPPointFMake(160.0, 21.0);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  // Redessine PaintBox1
  PaintBox1.Repaint;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var H,M,S,Z : word;
begin
  // decode l'heure systeme
  DecodeTime(now, h, m, s, z);

  // dessine l'horloge grace a GDI+
  GPDrawHorloge(H, M, S, Z);
end;

procedure TForm1.GPDrawHorloge(const H,M,S,Z : word);
var N         : integer;
    HH,HM,
    HS,HZ     : single;
    gpDrawer  : TGPGraphics;
    gpPen     : TGPPen;
    gpBrush   : TGPSolidBrush;
    gpFontFml : TGPFontFamily;
    gpFont    : TGPFont;
begin
  // ----- Creation des objets GDI+

    // outils de dessin GDI+ (necessite un contexte de dessin valide)
    gpDrawer := TGPGraphics.Create(PaintBox1.Canvas.Handle);
    gpDrawer.SetCompositingQuality(CompositingQualityHighQuality);
    gpDrawer.SetSmoothingMode(SmoothingModeAntiAlias);

    // crayon
    gpPen := TGPPen.Create(TextColor);

    // pinceau
    gpBrush := TGPSolidBrush.Create(GroundColor);

    // police d'ecriture
    gpFontFml := TGPFontFamily.Create('Lucida Console');
    // Utilisation de FontFamily
    //gpFont    := TGPFont.Create(gpFontFml, 9, FontStyleBold, UnitPoint);
    // ou directement de la police de paintbox1
    gpFont := TGPFont.Create(PaintBox1.Canvas.Handle, PaintBox1.Font.Handle);
  // -----

  // Transformation de Z, M, S, H.
  HZ := Z*0.06;
  HS := S + (Z*0.001);
  HM := M + (STM * HS);
  HH := ((H mod 12) * 5) + (HTM * HM);

  // effacement du fond
  gpDrawer.Clear( GroundColor );

  // "aiguilles"
  gpBrush.SetColor( PieColor );
  gpDrawer.FillPie(gpBrush,   6, 6, 40, 40, 270, HH * DTM);
  gpDrawer.FillPie(gpBrush,  54, 6, 40, 40, 270, HM * DTM);
  gpDrawer.FillPie(gpBrush, 102, 6, 40, 40, 270, HS * DTM);
  gpDrawer.FillPie(gpBrush, 150, 6, 40, 40, 270, HZ * DTM);

  // masque
  gpBrush.SetColor( GroundColor );
  gpDrawer.FillEllipse(gpBrush,  12, 12, 28, 28);
  gpDrawer.FillEllipse(gpBrush,  60, 12, 28, 28);
  gpDrawer.FillEllipse(gpBrush, 108, 12, 28, 28);
  gpDrawer.FillEllipse(gpBrush, 156, 12, 28, 28);

  // graduations
  N := 0;
  gpPen.SetColor(TextColor);
  gpPen.SetWidth(1);
  while N <= 55 do
  begin
    gpDrawer.DrawLine(gpPen, 26+PCS[N].Big.X,    26+PCS[N].Big.Y,
                             26+PCS[N].Small.X,  26+PCS[N].Small.Y);

    gpDrawer.DrawLine(gpPen, 74+PCS[N].Big.X,    26+PCS[N].Big.Y,
                             74+PCS[N].Small.X,  26+PCS[N].Small.Y);

    gpDrawer.DrawLine(gpPen, 122+PCS[N].Big.X,   26+PCS[N].Big.Y,
                             122+PCS[N].Small.X, 26+PCS[N].Small.Y);

    gpDrawer.DrawLine(gpPen, 170+PCS[N].Big.X,   26+PCS[N].Big.Y,
                             170+PCS[N].Small.X, 26+PCS[N].Small.Y);
    N := N + 5;
  end;

  // contours
  gpPen.SetWidth(2);
  gpDrawer.DrawEllipse(gpPen,4, 4, 44, 44);
  gpDrawer.DrawEllipse(gpPen,52, 4, 44, 44);
  gpDrawer.DrawEllipse(gpPen,100, 4, 44, 44);
  gpDrawer.DrawEllipse(gpPen,148, 4, 44, 44);

  // textes
  gpBrush.SetColor( TextColor );
  gpDrawer.DrawString(format('%.2d',[H]),        -1, gpFont, CPtHour, gpBrush);
  gpDrawer.DrawString(format('%.2d',[M]),        -1, gpFont, CPtMin,  gpBrush);
  gpDrawer.DrawString(format('%.2d',[S]),        -1, gpFont, CPtSec,  gpBrush);
  gpDrawer.DrawString(format('%.2d',[Z div 10]), -1, gpFont, CPtMSec, gpBrush);

  // ----- Liberation des objets GDI+ (ordre inverse de creation)
  gpFont.Free;
  gpFontFml.Free;
  gpBrush.Free;
  gpPen.Free;
  gpDrawer.Free;
end;


end.
