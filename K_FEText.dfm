inherited K_FormTextEdit: TK_FormTextEdit
  Left = 395
  Top = 266
  Width = 353
  Height = 168
  Caption = ''
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    337
    129)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 335
    Top = 124
    TabOrder = 3
  end
  object BtCancel: TButton
    Left = 266
    Top = 108
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 0
    OnClick = BtFormCloselClick
  end
  object BtOK: TButton
    Left = 178
    Top = 108
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    OnClick = BtOKClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 345
    Height = 101
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    object MMemo: TMemo
      Left = 1
      Top = 1
      Width = 160
      Height = 72
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
    end
    object REMemo: TRichEdit
      Left = 184
      Top = 1
      Width = 145
      Height = 73
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 1
      Visible = False
    end
  end
end
