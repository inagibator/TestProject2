object N_MsgDialogForm: TN_MsgDialogForm
  Left = 268
  Top = 265
  Width = 328
  Height = 184
  Caption = 'N_MsgDialogForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  DesignSize = (
    320
    146)
  PixelsPerInch = 96
  TextHeight = 13
  object lbMessage: TLabel
    Left = 15
    Top = 12
    Width = 297
    Height = 103
    Anchors = [akLeft, akTop, akRight, akBottom]
    AutoSize = False
    Caption = 'lbMessage'
    WordWrap = True
  end
  object bnOK: TButton
    Left = 20
    Top = 118
    Width = 69
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
    Visible = False
  end
  object bnCancel: TButton
    Left = 95
    Top = 118
    Width = 69
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    Visible = False
  end
  object bnYes: TButton
    Left = 170
    Top = 118
    Width = 68
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Yes'
    ModalResult = 6
    TabOrder = 2
    Visible = False
  end
  object bnNo: TButton
    Left = 246
    Top = 118
    Width = 69
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'No'
    ModalResult = 7
    TabOrder = 3
    Visible = False
  end
  object Button1: TButton
    Left = 20
    Top = 86
    Width = 69
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1053#1077#1090' '#1076#1083#1103' '#1074#1089#1077#1093
    ModalResult = 1
    TabOrder = 4
    Visible = False
  end
end
