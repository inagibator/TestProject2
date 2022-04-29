object Form1: TForm1
  Left = 234
  Top = 351
  Width = 857
  Height = 319
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 264
    Top = 160
    Width = 401
    Height = 18
    Caption = 'Panel1'
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 255
      Top = 1
      Width = 1
      Height = 16
      Align = alRight
    end
    object Splitter2: TSplitter
      Left = 193
      Top = 1
      Width = 1
      Height = 16
    end
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 192
      Height = 16
      Align = alLeft
      Caption = 'Panel2'
      Constraints.MinWidth = 1
      TabOrder = 0
    end
    object Panel3: TPanel
      Left = 194
      Top = 1
      Width = 61
      Height = 16
      Align = alClient
      Color = clAppWorkSpace
      UseDockManager = False
      TabOrder = 1
    end
    object Panel4: TPanel
      Left = 256
      Top = 1
      Width = 144
      Height = 16
      Align = alRight
      Caption = 'Panel4'
      Constraints.MinWidth = 1
      TabOrder = 2
    end
  end
end
