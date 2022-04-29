object N_GetUObjForm: TN_GetUObjForm
  Left = 511
  Top = 208
  Width = 242
  Height = 296
  Caption = 'N_GetUObjForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  inline VTreeFrame: TN_VTreeFrame
    Left = 0
    Top = 0
    Width = 234
    Height = 262
    Align = alClient
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 0
    inherited TreeView: TTreeView
      Width = 234
      Height = 262
    end
  end
end
