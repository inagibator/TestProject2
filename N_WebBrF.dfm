object N_WebBrForm: TN_WebBrForm
  Left = 700
  Top = 298
  Width = 178
  Height = 183
  Caption = 'N_WebBrForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object WebBr: TWebBrowser
    Left = 0
    Top = 29
    Width = 170
    Height = 120
    Align = alClient
    TabOrder = 0
    ControlData = {
      4C00000092110000670C00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E12620C000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 170
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Action = aGoBack
    end
    object ToolButton2: TToolButton
      Left = 25
      Top = 2
      Action = aRefresh
    end
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 136
    object aRefresh: TAction
      Caption = 'Refresh'
      Hint = 'Refresh'
      ImageIndex = 38
      OnExecute = aRefreshExecute
    end
    object aGoBack: TAction
      Caption = 'aGoBack'
      ImageIndex = 76
      OnExecute = aGoBackExecute
    end
  end
end
