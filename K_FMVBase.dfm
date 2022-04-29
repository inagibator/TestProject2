inherited K_FormMVBase: TK_FormMVBase
  Height = 150
  Caption = 'K_FormMVBase'
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Top = 104
    TabOrder = 2
  end
  inherited Panel1: TPanel
    Top = 91
  end
  inline FrameRAEdit: TK_FrameRAEdit
    Left = 0
    Top = 0
    Width = 303
    Height = 91
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    inherited SGrid: TStringGrid
      Width = 303
      Height = 91
    end
  end
end
