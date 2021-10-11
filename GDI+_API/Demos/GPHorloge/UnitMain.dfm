object Form1: TForm1
  Left = 205
  Top = 120
  AlphaBlend = True
  BorderStyle = bsToolWindow
  Caption = 'GDI+ Horloge'
  ClientHeight = 56
  ClientWidth = 198
  Color = clBtnFace
  TransparentColorValue = clBlue
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  ScreenSnap = True
  SnapBuffer = 20
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox1: TPaintBox
    Left = 0
    Top = 0
    Width = 198
    Height = 56
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Lucida Console'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    OnPaint = PaintBox1Paint
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 8
    Top = 8
  end
end
