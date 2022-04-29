inherited N_CMCaptDev29aForm: TN_CMCaptDev29aForm
  Left = 160
  Top = 627
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Morita'
  ClientHeight = 233
  ClientWidth = 274
  OldCreateOrder = True
  OnShow = FormShow
  ExplicitWidth = 290
  ExplicitHeight = 272
  DesignSize = (
    274
    233)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 288
    Top = 214
    ExplicitLeft = 288
    ExplicitTop = 214
  end
  object bnOK: TButton
    Left = 215
    Top = 190
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    TabStop = False
    OnClick = bnOKClick
  end
  object RadioGroup1: TRadioGroup
    Left = 24
    Top = 16
    Width = 145
    Height = 57
    Caption = 'Viewer Settings'
    ItemIndex = 0
    Items.Strings = (
      'CMS 3D'
      'i-Dixel')
    TabOrder = 2
  end
  object GroupBox1: TGroupBox
    Left = 24
    Top = 79
    Width = 209
    Height = 98
    Caption = 'Auto-Login Settings'
    TabOrder = 3
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 32
      Height = 13
      Caption = 'Login: '
    end
    object Label2: TLabel
      Left = 16
      Top = 56
      Width = 49
      Height = 13
      Caption = 'Password:'
    end
    object edLogin: TEdit
      Left = 71
      Top = 21
      Width = 121
      Height = 21
      TabOrder = 0
    end
    object edPassword: TEdit
      Left = 71
      Top = 51
      Width = 121
      Height = 21
      PasswordChar = '*'
      TabOrder = 1
    end
  end
end
