object N_MainFormFrame: TN_MainFormFrame
  Left = 0
  Top = 0
  Width = 140
  Height = 43
  Color = clSilver
  ParentColor = False
  TabOrder = 0
  object OpenDialog: TOpenDialog
    Filter = 
      'Binary file  (*.sdb)|*.SDB|Text file   (.sdt)|*.SDT|Show All fil' +
      'es  (*.*)|*.*'
    Left = 70
    Top = 2
  end
  object MainFormFrameActList: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 6
    Top = 2
    object OthSaveCurState: TAction
      Category = 'Others'
      Caption = 'Save Current State'
      ImageIndex = 5
      OnExecute = OthSaveCurStateExecute
    end
    object aFileArchNew: TAction
      Category = 'File'
      Caption = 'Archive New'
      Hint = 'Create New Archive'
      ImageIndex = 0
      OnExecute = aFileArchNewExecute
    end
    object aFileArchOpen: TAction
      Category = 'File'
      Caption = 'Archive Open ...'
      Hint = 'Open Archive (+Shift - toggle sdt <-> sdb)'
      ImageIndex = 1
      OnExecute = aFileArchOpenExecute
    end
    object aFileArchSelect: TAction
      Category = 'File'
      Caption = 'Archive Select'
      Hint = 'Select Archive from already opened Archives'
      ImageIndex = 23
      OnExecute = aFileArchSelectExecute
    end
    object aFileArchClose: TAction
      Category = 'File'
      Caption = 'Archive Close'
      Hint = 'Close Archive'
      ImageIndex = 16
      OnExecute = aFileArchCloseExecute
    end
    object aFileArchSave: TAction
      Category = 'File'
      Caption = 'Archive Save'
      Hint = 'Save Archive (+Shift - toggle sdt <-> sdb)'
      ImageIndex = 2
      OnExecute = aFileArchSaveExecute
    end
    object aFileArchSaveAs: TAction
      Category = 'File'
      Caption = 'Archive Save As ...'
      Hint = 'Save Archive As ... (+Shift - Inc FileName)'
      ImageIndex = 3
      OnExecute = aFileArchSaveAsExecute
    end
    object aFileNoSaveExit: TAction
      Category = 'File'
      Caption = 'Exit without saving'
      Hint = 'Exit without saving'
      ImageIndex = 152
      OnExecute = aFileNoSaveExitExecute
    end
    object ToolsDTreeEd: TAction
      Category = 'Tools'
      Caption = 'DTree Editor'
      ImageIndex = 49
      OnExecute = ToolsDTreeEdExecute
    end
    object aFormsImport: TAction
      Category = 'Forms'
      Caption = 'Import CObjects'
      Hint = 'Import Map Layers'
      ImageIndex = 4
      OnExecute = aFormsImportExecute
    end
    object aFormsExport: TAction
      Category = 'Forms'
      Caption = 'Export CObjects'
      Hint = 'Export Map Layers'
      ImageIndex = 5
      OnExecute = aFormsExportExecute
    end
    object aFormsNVtree: TAction
      Category = 'Forms'
      Caption = 'Show NVTree Form'
      Hint = 'Show NVTree Form'
      ImageIndex = 45
      OnExecute = aFormsNVtreeExecute
    end
    object DebPlatformInfo: TAction
      Category = 'Deb'
      Caption = 'Show Platform Info'
      OnExecute = DebPlatformInfoExecute
    end
    object DebSpeedTests: TAction
      Category = 'Deb'
      Caption = 'Speed Tests'
      OnExecute = DebSpeedTestsExecute
    end
    object DebShowTimers: TAction
      Category = 'Deb'
      Caption = 'Show Deb Timers'
      OnExecute = DebShowTimersExecute
    end
    object DebWrk1: TAction
      Category = 'Deb'
      Caption = 'Deb Action 1'
      ImageIndex = 95
      OnExecute = DebWrk1Execute
    end
    object DebWrk2: TAction
      Category = 'Deb'
      Caption = 'Deb Action 2'
      ImageIndex = 96
      OnExecute = DebWrk2Execute
    end
    object DebWrk3: TAction
      Category = 'Deb'
      Caption = 'Deb Action 3'
      ImageIndex = 97
      OnExecute = DebWrk3Execute
    end
    object DebShowDebForm: TAction
      Category = 'Deb'
      Caption = 'Show DebForm'
      OnExecute = DebShowDebFormExecute
    end
    object ToolsPlainEditor: TAction
      Category = 'Tools'
      Caption = 'Plain Text Editor'
      ImageIndex = 29
      OnExecute = ToolsPlainEditorExecute
    end
    object ToolsRichEditor: TAction
      Category = 'Tools'
      Caption = 'Rich Text Editor'
      ImageIndex = 29
      OnExecute = ToolsRichEditorExecute
    end
    object ToolsRunSPLScript: TAction
      Category = 'Tools'
      Caption = 'Run SPL Script'
      ImageIndex = 99
      OnExecute = ToolsRunSPLScriptExecute
    end
    object ToolsSPLEnv: TAction
      Category = 'Tools'
      Caption = 'SPL Environment'
      ImageIndex = 40
      OnExecute = ToolsSPLEnvExecute
    end
    object ToolsCDimEditor: TAction
      Category = 'Tools'
      Caption = 'Codes Dimension Editor'
      ImageIndex = 181
      OnExecute = ToolsCDimEditorExecute
    end
    object ToolsCSDimEditor: TAction
      Category = 'Tools'
      Caption = 'Codes SubDimension Editor'
      ImageIndex = 182
      OnExecute = ToolsCSDimEditorExecute
    end
    object ToolsCSDimRelEditor: TAction
      Category = 'Tools'
      Caption = 'Codes SubDim. Relation Editor'
      ImageIndex = 183
      OnExecute = ToolsCSDimRelEditorExecute
    end
    object ToolsDataBlockEditor: TAction
      Category = 'Tools'
      Caption = 'Data Block Editor'
      ImageIndex = 184
      OnExecute = ToolsDataBlockEditorExecute
    end
    object ToolsCSEditor: TAction
      Category = 'Tools'
      Caption = 'Codes Space Editor'
      ImageIndex = 77
      OnExecute = ToolsCSEditorExecute
    end
    object ToolsCSSEditor: TAction
      Category = 'Tools'
      Caption = 'Codes SubSpace Editor'
      ImageIndex = 78
      OnExecute = ToolsCSSEditorExecute
    end
    object aFormsParams1: TAction
      Category = 'Forms'
      Caption = 'Show Params1 Form'
      Hint = 'Show Params1Form'
      ImageIndex = 137
      OnExecute = aFormsParams1Execute
    end
    object aFormsDebProcs: TAction
      Category = 'Forms'
      Caption = 'Show DebProcsForm'
      Hint = 'Show DebProcsForm'
      ImageIndex = 113
      OnExecute = aFormsDebProcsExecute
    end
    object aFormsWebBrowser: TAction
      Category = 'Forms'
      Caption = 'Show Web Browser'
      Hint = 'Show Web Browser'
      ImageIndex = 20
      OnExecute = aFormsWebBrowserExecute
    end
    object DebCreateRusRaster: TAction
      Category = 'Deb'
      Caption = 'Create RusRaster'
    end
    object ToolsCSProjEditor: TAction
      Category = 'Tools'
      Caption = 'Codes Space Projection Editor'
      ImageIndex = 72
      OnExecute = ToolsCSProjEditorExecute
    end
    object aEditGlobalOptions: TAction
      Category = 'Edit'
      Caption = 'Edit Global Options'
      Hint = 'Edit Global Options'
      ImageIndex = 134
      OnExecute = aEditGlobalOptionsExecute
    end
    object ViewProtocol: TAction
      Category = 'View'
      Caption = 'View Protocol'
      ImageIndex = 126
      OnExecute = ViewProtocolExecute
    end
    object OthRefreshSclonTable: TAction
      Category = 'Others'
      Caption = 'Refresh Sclon Table'
      OnExecute = OthRefreshSclonTableExecute
    end
    object DebQuitOLEServers: TAction
      Category = 'Deb'
      Caption = 'Quit All OLE Servers'
      ImageIndex = 24
      OnExecute = DebQuitOLEServersExecute
    end
    object DebViewOLEServer: TAction
      Category = 'Deb'
      Caption = 'View One OLE Server'
      ImageIndex = 20
      OnExecute = DebViewOLEServerExecute
    end
    object DebSetDefCursor: TAction
      Category = 'Deb'
      Caption = 'Set Default Cursor'
      ImageIndex = 178
      OnExecute = DebSetDefCursorExecute
    end
  end
  object SaveDialog: TSaveDialog
    Filter = 
      'Binary file  (*.sdb)|*.SDB|Text file   (.sdt)|*.SDT|Show All fil' +
      'es  (*.*)|*.*'
    Title = 'Save Archive As'
    Left = 38
    Top = 2
  end
end
