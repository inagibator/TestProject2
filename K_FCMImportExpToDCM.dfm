inherited K_FormCMImportExpToDCM: TK_FormCMImportExpToDCM
  Left = 463
  Top = 341
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Export to DICOM last imported'
  ClientHeight = 170
  ClientWidth = 446
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel [0]
    Left = 16
    Top = 51
    Width = 417
    Height = 27
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsFrame
  end
  object Bevel3: TBevel [1]
    Left = 16
    Top = 76
    Width = 417
    Height = 27
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsFrame
  end
  object Bevel2: TBevel [2]
    Left = 16
    Top = 101
    Width = 417
    Height = 27
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsFrame
  end
  object Label2: TLabel [3]
    Left = 24
    Top = 57
    Width = 209
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Last import date'
  end
  object LbIDate: TLabel [4]
    Left = 188
    Top = 57
    Width = 230
    Height = 13
    Alignment = taRightJustify
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
    Caption = '00'
  end
  object Label5: TLabel [5]
    Left = 24
    Top = 81
    Width = 207
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Last import time'
  end
  object LbITime: TLabel [6]
    Left = 180
    Top = 81
    Width = 238
    Height = 13
    Alignment = taRightJustify
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
    Caption = '00'
  end
  object Label3: TLabel [7]
    Left = 24
    Top = 106
    Width = 212
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Imported objects'
  end
  object LbICount: TLabel [8]
    Left = 188
    Top = 106
    Width = 230
    Height = 13
    Alignment = taRightJustify
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
    Caption = '00'
  end
  object LbExpCount: TLabel [9]
    Left = 18
    Top = 142
    Width = 269
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
    Caption = ' 1111 deleted objects'
  end
  inherited BFMinBRPanel: TPanel
    Left = 436
    Top = 160
    TabOrder = 2
  end
  object BtCancel: TButton
    Left = 367
    Top = 139
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Exit'
    ModalResult = 2
    TabOrder = 0
  end
  object BtStart: TButton
    Left = 298
    Top = 139
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Start'
    TabOrder = 1
    OnClick = BtStartClick
  end
  inline FPathNameFrame: TK_FPathNameFrame
    Tag = 161
    Left = 16
    Top = 8
    Width = 417
    Height = 28
    TabOrder = 3
    inherited LbPathName: TLabel
      Left = 2
      Width = 64
      Caption = 'Export path :'
    end
    inherited mbPathName: TComboBox
      Left = 80
      Width = 310
    end
    inherited bnBrowse_1: TButton
      Left = 392
      Top = 2
    end
  end
end
