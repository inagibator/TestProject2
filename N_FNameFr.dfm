object N_FileNameFrame: TN_FileNameFrame
  Tag = 161
  Left = 0
  Top = 0
  Width = 243
  Height = 27
  PopupMenu = FilePopupMenu
  TabOrder = 0
  DesignSize = (
    243
    27)
  object Label1: TLabel
    Left = 6
    Top = 5
    Width = 53
    Height = 13
    Caption = 'File Name :'
  end
  object mbFileName: TComboBox
    Left = 64
    Top = 3
    Width = 153
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    DropDownCount = 20
    ItemHeight = 13
    PopupMenu = FilePopupMenu
    TabOrder = 0
    OnChange = mbFileNameChange
    OnCloseUp = mbFileNameCloseUp
    OnContextPopup = mbFileNameContextPopup
    OnDblClick = aViewByExtensionExecute
    OnKeyDown = mbFileNameKeyDown
  end
  object bnBrowse_1: TButton
    Left = 219
    Top = 3
    Width = 23
    Height = 21
    Anchors = [akTop, akRight]
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = bnBrowse_1Click
  end
  object OpenDialog: TOpenDialog
    Left = 69
  end
  object OpenPictureDialog: TOpenPictureDialog
    Left = 98
  end
  object FilePopupMenu: TPopupMenu
    Images = N_ButtonsForm.ButtonsList
    OnPopup = FilePopupMenuPopup
    Left = 129
    Top = 1
    object ViewFileAsText1: TMenuItem
      Action = aViewByExtension
    end
    object ViewFileAsPlainText1: TMenuItem
      Action = aViewAsPlainText
    end
    object ViewFileAsRichText1: TMenuItem
      Action = aViewAsRichText
    end
    object ViewFileAsWEBDocument1: TMenuItem
      Action = aViewAsWEB
    end
    object ViewFileAsHex1: TMenuItem
      Action = aViewAsHex
    end
    object ViewFileAsPicture1: TMenuItem
      Action = aViewAsPict
    end
    object aViewAVIInfo1: TMenuItem
      Action = aViewAVIInfo
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object aCreateTXT1: TMenuItem
      Action = aCreate
    end
    object CopyFile1: TMenuItem
      Action = aCopy
    end
    object RenameFile1: TMenuItem
      Action = aRename
    end
    object DeleteFile1: TMenuItem
      Action = aDelete
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miCompileSPLFile: TMenuItem
      Action = aCompile
    end
  end
  object FNameActList: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 158
    Top = 2
    object aViewByExtension: TAction
      Caption = 'View File'
      ImageIndex = 11
      OnExecute = aViewByExtensionExecute
    end
    object aViewAsPlainText: TAction
      Caption = 'View File As Plain Text'
      ImageIndex = 161
      OnExecute = aViewAsPlainTextExecute
    end
    object aViewAsRichText: TAction
      Caption = 'View File As Rich Text'
      ImageIndex = 163
      OnExecute = aViewAsRichTextExecute
    end
    object aViewAsWEB: TAction
      Caption = 'View File As WEB Document'
      ImageIndex = 164
      OnExecute = aViewAsWEBExecute
    end
    object aViewAsHex: TAction
      Caption = 'View File As Hex'
      ImageIndex = 162
      OnExecute = aViewAsHexExecute
    end
    object aViewAsPict: TAction
      Caption = 'View File As Picture'
      ImageIndex = 160
      OnExecute = aViewAsPictExecute
    end
    object aViewAVIInfo: TAction
      Caption = 'View AVI File Info'
      ImageIndex = 108
      OnExecute = aViewAVIInfoExecute
    end
    object aCreate: TAction
      Caption = 'Create New File'
      ImageIndex = 0
      OnExecute = aCreateExecute
    end
    object aCopy: TAction
      Caption = 'Copy File'
      ImageIndex = 12
      OnExecute = aCopyExecute
    end
    object aRename: TAction
      Caption = 'Rename File'
      ImageIndex = 19
      OnExecute = aRenameExecute
    end
    object aDelete: TAction
      Caption = 'Delete File'
      ImageIndex = 17
      OnExecute = aDeleteExecute
    end
    object aCompile: TAction
      Caption = 'Compile SPL File'
      ImageIndex = 40
      OnExecute = aCompileExecute
    end
  end
end
