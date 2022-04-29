inherited K_FormCDRelShow: TK_FormCDRelShow
  Left = 787
  Top = 321
  Width = 205
  Height = 238
  Caption = #1054#1090#1085#1086#1096#1077#1085#1080#1077
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 185
    Top = 192
    TabOrder = 1
  end
  inline FrameCDRel: TK_FrameCDRel
    Left = 0
    Top = 0
    Width = 197
    Height = 204
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    inherited SGrid: TStringGrid
      Width = 197
      Height = 204
    end
  end
end
