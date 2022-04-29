inherited N_CMCaptDev31aForm: TN_CMCaptDev31aForm
  Left = 160
  Top = 627
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Slida'
  ClientHeight = 222
  ClientWidth = 423
  OldCreateOrder = True
  OnShow = FormShow
  ExplicitWidth = 439
  ExplicitHeight = 261
  DesignSize = (
    423
    222)
  PixelsPerInch = 96
  TextHeight = 13
  object lbLineNumber: TLabel [0]
    Left = 13
    Top = 138
    Width = 145
    Height = 13
    Caption = 'Accept Patient Image Number:'
    Visible = False
  end
  object lbOrderNumber: TLabel [1]
    Left = 12
    Top = 101
    Width = 144
    Height = 13
    Caption = 'Sidexis Starting Order Number:'
  end
  object lbName: TLabel [2]
    Left = 13
    Top = 47
    Width = 69
    Height = 13
    Caption = 'Mailslot Name:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 445
    Top = 185
    ExplicitLeft = 445
    ExplicitTop = 185
  end
  object bnOK: TButton
    Left = 372
    Top = 161
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    TabStop = False
    OnClick = bnOKClick
  end
  inline SrcMailslotFrame: TK_FPathNameFrame
    Tag = 161
    Left = 8
    Top = 16
    Width = 433
    Height = 27
    TabOrder = 2
    ExplicitLeft = 8
    ExplicitTop = 16
    ExplicitWidth = 433
    ExplicitHeight = 27
    DesignSize = (
      433
      27)
    inherited LbPathName: TLabel
      Left = 5
      Top = 7
      Width = 63
      Caption = 'Mailslot Path:'
      ExplicitLeft = 5
      ExplicitTop = 7
      ExplicitWidth = 63
    end
    inherited mbPathName: TComboBox
      Left = 74
      Width = 312
      ExplicitLeft = 74
      ExplicitWidth = 312
    end
    inherited bnBrowse_1: TButton
      Left = 392
      ExplicitLeft = 392
    end
  end
  inline SrcImagesFrame: TK_FPathNameFrame
    Tag = 161
    Left = 8
    Top = 68
    Width = 433
    Height = 27
    TabOrder = 3
    ExplicitLeft = 8
    ExplicitTop = 68
    ExplicitWidth = 433
    ExplicitHeight = 27
    DesignSize = (
      433
      27)
    inherited LbPathName: TLabel
      Left = 5
      Top = 7
      Width = 100
      Caption = 'Sidexis'#39' Images Path:'
      ExplicitLeft = 5
      ExplicitTop = 7
      ExplicitWidth = 100
    end
    inherited mbPathName: TComboBox
      Left = 111
      Width = 275
      ExplicitLeft = 111
      ExplicitWidth = 275
    end
    inherited bnBrowse_1: TButton
      Left = 392
      ExplicitLeft = 392
    end
  end
  object edNumber: TEdit
    Left = 164
    Top = 138
    Width = 230
    Height = 21
    TabOrder = 4
    Text = '1'
    Visible = False
  end
  object edOrderNumber: TEdit
    Left = 162
    Top = 98
    Width = 149
    Height = 21
    TabOrder = 5
    Text = '2'
  end
  object Apply: TButton
    Left = 319
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Apply'
    TabOrder = 6
    OnClick = ApplyClick
  end
  object edMailslotName: TEdit
    Left = 82
    Top = 44
    Width = 312
    Height = 21
    TabOrder = 7
  end
end
