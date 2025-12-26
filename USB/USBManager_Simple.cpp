#define UNICODE
#define _UNICODE

#include <windows.h>
#include <windowsx.h>
#include <commctrl.h>
#include <shlobj.h>
#include <setupapi.h>
#include <winioctl.h>
#include <initguid.h>
#include <cfgmgr32.h>
#include <devguid.h>
#include <lmcons.h>
#include <string>
#include <vector>
#include <sstream>
#include <iomanip>
#include <fstream>
#include <filesystem>

#pragma comment(lib, "user32.lib")
#pragma comment(lib, "gdi32.lib")
#pragma comment(lib, "comctl32.lib")
#pragma comment(lib, "setupapi.lib")
#pragma comment(lib, "cfgmgr32.lib")
#pragma comment(lib, "shell32.lib")
#pragma comment(lib, "comdlg32.lib")
#pragma comment(lib, "advapi32.lib")

namespace fs = std::filesystem;

// Global variables
HWND g_hListDevices = NULL;
HWND g_hListFiles = NULL;
HWND g_hEditText = NULL;
HWND g_hStatusBar = NULL;
HWND g_hMainWnd = NULL;
std::wstring g_selectedDrive = L"";
std::wstring g_currentUser = L"";

// Get current logged in user
std::wstring GetCurrentUser() {
    wchar_t username[UNLEN + 1];
    DWORD username_len = UNLEN + 1;
    
    if (GetUserNameW(username, &username_len)) {
        return std::wstring(username);
    }
    return L"Unknown User";
}

// Get all USB drives
std::vector<std::wstring> GetUSBDrives() {
    std::vector<std::wstring> drives;
    wchar_t buffer[MAX_PATH];
    
    if (GetLogicalDriveStringsW(MAX_PATH, buffer)) {
        wchar_t* drive = buffer;
        while (*drive) {
            UINT type = GetDriveTypeW(drive);
            if (type == DRIVE_REMOVABLE) {
                drives.push_back(drive);
            }
            drive += wcslen(drive) + 1;
        }
    }
    
    return drives;
}

// Get drive information
struct DriveInfo {
    std::wstring driveLetter;
    std::wstring serialNumber;
    ULONGLONG totalSize;
    ULONGLONG freeSpace;
};

bool GetDriveInfo(const std::wstring& drive, DriveInfo& info) {
    // Get disk space
    ULARGE_INTEGER totalBytes, freeBytes;
    if (GetDiskFreeSpaceExW(drive.c_str(), NULL, &totalBytes, &freeBytes)) {
        info.totalSize = totalBytes.QuadPart;
        info.freeSpace = freeBytes.QuadPart;
    }
    
    // Get volume serial number
    wchar_t volumeName[MAX_PATH];
    wchar_t fileSystem[MAX_PATH];
    DWORD serialNumber = 0;
    DWORD maxComponentLen = 0;
    DWORD fileSystemFlags = 0;
    
    if (GetVolumeInformationW(drive.c_str(), volumeName, MAX_PATH, 
                            &serialNumber, &maxComponentLen, 
                            &fileSystemFlags, fileSystem, MAX_PATH)) {
        std::wstringstream ss;
        ss << std::hex << std::setw(8) << std::setfill(L'0') << serialNumber;
        info.serialNumber = ss.str();
        info.driveLetter = drive;
        return true;
    }
    
    return false;
}

// Update USB device list
void UpdateDeviceList() {
    // Clear list
    ListView_DeleteAllItems(g_hListDevices);
    
    std::vector<std::wstring> drives = GetUSBDrives();
    
    for (int i = 0; i < (int)drives.size(); i++) {
        DriveInfo info;
        if (GetDriveInfo(drives[i], info)) {
            // Add drive letter
            LVITEM item = {0};
            item.mask = LVIF_TEXT;
            item.iItem = i;
            item.iSubItem = 0;
            item.pszText = (LPWSTR)info.driveLetter.c_str();
            ListView_InsertItem(g_hListDevices, &item);
            
            // Add serial number
            ListView_SetItemText(g_hListDevices, i, 1, (LPWSTR)info.serialNumber.c_str());
            
            // Format size info
            wchar_t totalSize[32], freeSpace[32];
            _ui64tow(info.totalSize / (1024*1024), totalSize, 10);
            _ui64tow(info.freeSpace / (1024*1024), freeSpace, 10);
            
            std::wstring totalStr = std::wstring(totalSize) + L" MB";
            std::wstring freeStr = std::wstring(freeSpace) + L" MB";
            
            ListView_SetItemText(g_hListDevices, i, 2, (LPWSTR)totalStr.c_str());
            ListView_SetItemText(g_hListDevices, i, 3, (LPWSTR)freeStr.c_str());
        }
    }
}

// Refresh USB file list
void RefreshFileList() {
    int selected = ListView_GetNextItem(g_hListDevices, -1, LVNI_SELECTED);
    if (selected >= 0) {
        wchar_t driveLetter[10] = {0};
        ListView_GetItemText(g_hListDevices, selected, 0, driveLetter, 10);
        
        g_selectedDrive = driveLetter;
        
        // Update file list
        SendMessage(g_hListFiles, LB_RESETCONTENT, 0, 0);
        
        try {
            for (const auto& entry : fs::directory_iterator(g_selectedDrive)) {
                std::wstring filename = entry.path().filename().wstring();
                SendMessage(g_hListFiles, LB_ADDSTRING, 0, (LPARAM)filename.c_str());
            }
        } catch (...) {
            // Handle exception
        }
        
        std::wstring status = L"Selected Drive: " + g_selectedDrive;
        SendMessage(g_hStatusBar, SB_SETTEXT, 0, (LPARAM)status.c_str());
    }
}

// Write text to USB - FIXED VERSION
void WriteTextToUSB() {
    if (g_selectedDrive.empty()) {
        MessageBox(g_hMainWnd, L"Please select a USB drive first", L"Info", MB_OK | MB_ICONINFORMATION);
        return;
    }
    
    wchar_t text[1024] = {0};
    GetWindowText(g_hEditText, text, 1024);
    
    if (wcslen(text) == 0) {
        MessageBox(g_hMainWnd, L"Please enter text to write", L"Info", MB_OK | MB_ICONINFORMATION);
        return;
    }
    
    std::wstring filePath = g_selectedDrive + std::wstring(L"USB_Note.txt");
    
    // 方法1: 使用filesystem::path
    fs::path filePathObj(filePath);
    
    // 方法2: 使用fstream的open方法，传递const char*（需要转换编码）
    // 或者使用wofstream的open方法
    std::wofstream file;
    
    // 尝试使用UTF-8编码打开文件
    #ifdef _MSC_VER
        // MSVC编译器
        file.open(filePath);
    #else
        // MinGW编译器
        // 将宽字符串转换为UTF-8字符串
        std::string utf8Path;
        int size = WideCharToMultiByte(CP_UTF8, 0, filePath.c_str(), -1, NULL, 0, NULL, NULL);
        if (size > 0) {
            std::vector<char> buffer(size);
            WideCharToMultiByte(CP_UTF8, 0, filePath.c_str(), -1, &buffer[0], size, NULL, NULL);
            utf8Path = &buffer[0];
        }
        file.open(utf8Path.c_str());
    #endif
    
    if (file.is_open()) {
        file << text;
        file.close();
        MessageBox(g_hMainWnd, L"Text written to USB successfully", L"Success", MB_OK | MB_ICONINFORMATION);
        RefreshFileList();
    } else {
        MessageBox(g_hMainWnd, L"Write failed, check if USB is writable", L"Error", MB_OK | MB_ICONERROR);
    }
}

// Transfer file to USB
void TransferFileToUSB() {
    if (g_selectedDrive.empty()) {
        MessageBox(g_hMainWnd, L"Please select a USB drive first", L"Info", MB_OK | MB_ICONINFORMATION);
        return;
    }
    
    wchar_t filename[MAX_PATH] = {0};
    
    OPENFILENAME ofn = {0};
    ofn.lStructSize = sizeof(ofn);
    ofn.hwndOwner = g_hMainWnd;
    ofn.lpstrFile = filename;
    ofn.nMaxFile = MAX_PATH;
    ofn.lpstrFilter = L"All Files\0*.*\0";
    ofn.nFilterIndex = 1;
    ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;
    
    if (GetOpenFileName(&ofn)) {
        std::wstring sourcePath = filename;
        std::wstring destPath = g_selectedDrive + fs::path(sourcePath).filename().wstring();
        
        try {
            // 使用filesystem库复制文件
            fs::path src(sourcePath);
            fs::path dst(destPath);
            fs::copy_file(src, dst, fs::copy_options::overwrite_existing);
            MessageBox(g_hMainWnd, L"File transferred to USB successfully", L"Success", MB_OK | MB_ICONINFORMATION);
            RefreshFileList();
        } catch (...) {
            MessageBox(g_hMainWnd, L"File transfer failed", L"Error", MB_OK | MB_ICONERROR);
        }
    }
}

// Delete file from USB
void DeleteUSBFile() {
    if (g_selectedDrive.empty()) {
        MessageBox(g_hMainWnd, L"Please select a USB drive first", L"Info", MB_OK | MB_ICONINFORMATION);
        return;
    }
    
    int selected = SendMessage(g_hListFiles, LB_GETCURSEL, 0, 0);
    if (selected != LB_ERR) {
        wchar_t filename[256] = {0};
        SendMessage(g_hListFiles, LB_GETTEXT, selected, (LPARAM)filename);
        
        std::wstring fullPath = g_selectedDrive + std::wstring(filename);
        
        int result = MessageBox(g_hMainWnd, L"Are you sure you want to delete this file?", L"Confirm Delete", 
                               MB_YESNO | MB_ICONQUESTION);
        
        if (result == IDYES) {
            try {
                // 使用filesystem库删除文件
                if (fs::remove(fs::path(fullPath))) {
                    MessageBox(g_hMainWnd, L"File deleted successfully", L"Success", MB_OK | MB_ICONINFORMATION);
                    RefreshFileList();
                } else {
                    MessageBox(g_hMainWnd, L"Delete failed", L"Error", MB_OK | MB_ICONERROR);
                }
            } catch (...) {
                MessageBox(g_hMainWnd, L"Delete failed, file may be in use", L"Error", MB_OK | MB_ICONERROR);
            }
        }
    } else {
        MessageBox(g_hMainWnd, L"Please select a file from the list first", L"Info", MB_OK | MB_ICONINFORMATION);
    }
}

// Create UI controls
void CreateControls(HWND hwnd) {
    // Current user label
    CreateWindow(L"STATIC", (L"Current User: " + g_currentUser).c_str(),
                WS_CHILD | WS_VISIBLE,
                10, 10, 300, 25, hwnd, NULL, GetModuleHandle(NULL), NULL);
    
    // USB devices list label
    CreateWindow(L"STATIC", L"USB Devices List:",
                WS_CHILD | WS_VISIBLE,
                10, 40, 200, 25, hwnd, NULL, GetModuleHandle(NULL), NULL);
    
    // Device list view
    g_hListDevices = CreateWindowEx(WS_EX_CLIENTEDGE, WC_LISTVIEW, L"",
                                   WS_CHILD | WS_VISIBLE | LVS_REPORT | LVS_SINGLESEL,
                                   10, 65, 560, 150, hwnd, (HMENU)100, GetModuleHandle(NULL), NULL);
    
    // Set columns
    LVCOLUMN lvc = {0};
    lvc.mask = LVCF_WIDTH | LVCF_TEXT | LVCF_SUBITEM;
    
    lvc.iSubItem = 0;
    lvc.cx = 80;
    lvc.pszText = L"Drive";
    ListView_InsertColumn(g_hListDevices, 0, &lvc);
    
    lvc.iSubItem = 1;
    lvc.cx = 120;
    lvc.pszText = L"Serial No.";
    ListView_InsertColumn(g_hListDevices, 1, &lvc);
    
    lvc.iSubItem = 2;
    lvc.cx = 120;
    lvc.pszText = L"Total Size";
    ListView_InsertColumn(g_hListDevices, 2, &lvc);
    
    lvc.iSubItem = 3;
    lvc.cx = 120;
    lvc.pszText = L"Free Space";
    ListView_InsertColumn(g_hListDevices, 3, &lvc);
    
    // Refresh button
    CreateWindow(L"BUTTON", L"Refresh List",
                WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
                580, 65, 100, 30, hwnd, (HMENU)101, GetModuleHandle(NULL), NULL);
    
    // File list label
    CreateWindow(L"STATIC", L"USB Files List:",
                WS_CHILD | WS_VISIBLE,
                10, 225, 200, 25, hwnd, NULL, GetModuleHandle(NULL), NULL);
    
    // File list box
    g_hListFiles = CreateWindowEx(WS_EX_CLIENTEDGE, L"LISTBOX", L"",
                                 WS_CHILD | WS_VISIBLE | WS_VSCROLL | LBS_NOTIFY,
                                 10, 250, 300, 200, hwnd, (HMENU)102, GetModuleHandle(NULL), NULL);
    
    // Text input label
    CreateWindow(L"STATIC", L"Text to write:",
                WS_CHILD | WS_VISIBLE,
                320, 225, 200, 25, hwnd, NULL, GetModuleHandle(NULL), NULL);
    
    // Text edit box
    g_hEditText = CreateWindowEx(WS_EX_CLIENTEDGE, L"EDIT", L"Enter text here...",
                                WS_CHILD | WS_VISIBLE | WS_BORDER | ES_MULTILINE | ES_AUTOVSCROLL,
                                320, 250, 200, 100, hwnd, (HMENU)103, GetModuleHandle(NULL), NULL);
    
    // Function buttons
    CreateWindow(L"BUTTON", L"Write Text to USB",
                WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
                320, 360, 150, 30, hwnd, (HMENU)104, GetModuleHandle(NULL), NULL);
    
    CreateWindow(L"BUTTON", L"Transfer File to USB",
                WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
                320, 400, 150, 30, hwnd, (HMENU)105, GetModuleHandle(NULL), NULL);
    
    CreateWindow(L"BUTTON", L"Delete Selected File",
                WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
                320, 440, 150, 30, hwnd, (HMENU)106, GetModuleHandle(NULL), NULL);
    
    // Status bar
    g_hStatusBar = CreateWindow(STATUSCLASSNAME, L"Ready",
                               WS_CHILD | WS_VISIBLE,
                               0, 0, 0, 0, hwnd, (HMENU)107, GetModuleHandle(NULL), NULL);
    
    // Initialize device list
    UpdateDeviceList();
}

// Window procedure
LRESULT CALLBACK WindowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
        case WM_CREATE:
            g_hMainWnd = hwnd;
            g_currentUser = GetCurrentUser();
            CreateControls(hwnd);
            return 0;
            
        case WM_SIZE: {
            // Adjust control sizes and positions
            RECT rcClient;
            GetClientRect(hwnd, &rcClient);
            
            // Adjust status bar
            SendMessage(g_hStatusBar, WM_SIZE, 0, 0);
            
            // Adjust device list width
            SetWindowPos(g_hListDevices, NULL, 0, 0, 
                        rcClient.right - 150, 150, 
                        SWP_NOMOVE | SWP_NOZORDER);
            
            return 0;
        }
            
        case WM_COMMAND: {
            int id = LOWORD(wParam);
            
            switch (id) {
                case 101: // Refresh device list
                    UpdateDeviceList();
                    SendMessage(g_hStatusBar, SB_SETTEXT, 0, (LPARAM)L"Device list refreshed");
                    break;
                    
                case 104: // Write text
                    WriteTextToUSB();
                    break;
                    
                case 105: // Transfer file
                    TransferFileToUSB();
                    break;
                    
                case 106: // Delete file
                    DeleteUSBFile();
                    break;
            }
            return 0;
        }
            
        case WM_NOTIFY: {
            LPNMHDR lpnmh = (LPNMHDR)lParam;
            if (lpnmh->idFrom == 100 && lpnmh->code == LVN_ITEMCHANGED) {
                RefreshFileList();
            }
            return 0;
        }
            
        case WM_DEVICECHANGE:
            // Refresh list when USB device is plugged in/out
            UpdateDeviceList();
            SendMessage(g_hStatusBar, SB_SETTEXT, 0, (LPARAM)L"USB device change detected");
            return 0;
            
        case WM_DESTROY:
            PostQuitMessage(0);
            return 0;
    }
    
    return DefWindowProc(hwnd, msg, wParam, lParam);
}

// Main function
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, 
                   LPSTR lpCmdLine, int nCmdShow) {
    
    // Initialize Common Controls
    INITCOMMONCONTROLSEX icex;
    icex.dwSize = sizeof(INITCOMMONCONTROLSEX);
    icex.dwICC = ICC_LISTVIEW_CLASSES | ICC_BAR_CLASSES;
    InitCommonControlsEx(&icex);
    
    // Register window class
    WNDCLASSEX wc = {0};
    wc.cbSize = sizeof(WNDCLASSEX);
    wc.style = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = hInstance;
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    wc.lpszClassName = L"USBSimpleMgr";
    wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
    
    RegisterClassEx(&wc);
    
    // Create window
    HWND hwnd = CreateWindowEx(
        0,
        L"USBSimpleMgr",
        L"USB Device Manager",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT,
        700, 550,
        NULL,
        NULL,
        hInstance,
        NULL
    );
    
    if (!hwnd) {
        MessageBox(NULL, L"Window creation failed", L"Error", MB_OK | MB_ICONERROR);
        return 1;
    }
    
    // Show window
    ShowWindow(hwnd, nCmdShow);
    UpdateWindow(hwnd);
    
    // Message loop
    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
    
    return (int)msg.wParam;
}