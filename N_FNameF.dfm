inherited N_FileNameForm: TN_FileNameForm
  Left = 467
  Top = 743
  Width = 273
  Height = 105
  Caption = 'Choose File Name'
  OldCreateOrder = True
  DesignSize = (
    265
    78)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 255
    Top = 62
    Height = 9
    TabOrder = 3
  end
  inline FileNameFrame: TN_FileNameFrame
    Tag = 161
    Left = 3
    Top = 7
    Width = 256
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    PopupMenu = FileNameFrame.FilePopupMenu
    TabOrder = 0
    inherited Label1: TLabel
      Left = 56
      Width = 3
      Caption = ''
    end
    inherited mbFileName: TComboBox
      Left = 8
      Width = 226
      OnChange = FileNameFramembFileNameChange
    end
    inherited bnBrowse_1: TButton
      Left = 236
      Width = 19
    end
    inherited OpenDialog: TOpenDialog
      Filter = 
        'All files (*.*)|*.*| Binary files (*.sdb)|*.SDB|Text files (*.tx' +
        't;*.sdm)|*.TXT;*.SDM'
      Left = 7
    end
    inherited OpenPictureDialog: TOpenPictureDialog
      Left = 17
    end
    inherited FilePopupMenu: TPopupMenu
      Left = 48
    end
    inherited FNameActList: TActionList
      Left = 77
    end
  end
  object bnCancel: TButton
    Left = 135
    Top = 46
    Width = 56
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object bnOK: TButton
    Left = 196
    Top = 46
    Width = 56
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1050
    ModalResult = 1
    TabOrder = 2
  end
end
