BÀI THỰC HÀNH 4: MINI E-COMMERCE APP (DỰ ÁN NHÓM)
Chủ đề: App Bán hàng cơ bản - Danh sách sản phẩm, Trang chi tiết, Giỏ hàng.
1. YÊU CẦU CHUNG
Hình thức: Làm việc theo nhóm (1 nhóm nộp chung 1 bài).
Mục tiêu: Tổng hợp kiến thức từ TH1 đến TH3 (UI, Local/Network Data, Điều hướng màn hình) và giải quyết bài toán quản lý trạng thái (State Management) liên màn hình.
Nguồn dữ liệu: Khuyến khích sử dụng FakeStore API , hoặc các nền tảng khác để dựng/lấy danh sách sản phẩm.
Định danh: Thanh AppBar ở trang chủ bắt buộc có cú pháp: TH4 - Nhóm [12].

2. YÊU CẦU CHỨC NĂNG & GIAO DIỆN (CHUẨN E-COMMERCE)
Dự án yêu cầu hoàn thiện luồng mua sắm khép kín với 4 màn hình cốt lõi. Giao diện ưu tiên bám sát trải nghiệm người dùng (UX) của các sàn TMĐT lớn như Shopee, Lazada.
MÀN HÌNH 1: TRANG CHỦ (HOME SCREEN) - Tối ưu hóa UI/UX
SliverAppBar & Hiệu ứng cuộn: * Thanh tìm kiếm (Search Bar) nằm ở trên cùng. Khi người dùng cuộn danh sách xuống, thanh tìm kiếm phải dính (sticky) ở đỉnh màn hình và đổi màu nền (từ trong suốt sang màu chủ đạo).
Góc phải trên cùng có Icon Giỏ hàng. Bắt buộc đính kèm một Badge (chấm đỏ hiện số) thể hiện tổng số loại sản phẩm đang có trong giỏ.
Banner Quảng cáo (Carousel Slider):
Khu vực dưới AppBar là một slider cuộn ngang tự động (Auto-play), hiển thị 3-4 ảnh banner khuyến mãi. Có các dấu chấm (dots indicator) để biết đang ở ảnh thứ mấy.
Danh mục Sản phẩm (Categories):
Một lưới Icon 2 hàng cuộn ngang (VD: Thời trang, Điện thoại, Mỹ phẩm, Đồ gia dụng...).
Gợi ý Hôm nay (Daily Discover - Infinite Scroll):
Sử dụng lưới GridView (2 cột) hoặc thư viện Masonry để hiển thị thẻ sản phẩm.
Cấu trúc Thẻ Sản phẩm (Product Card):
Ảnh sản phẩm (Có loading mờ khi chưa tải xong hình).
Tên sản phẩm (Giới hạn tối đa 2 dòng, quá dài phải cắt bằng dấu ...).
Tag nổi bật (VD: "Mall", "Yêu thích", "Giảm 50%").
Giá tiền: Phải format đúng chuẩn định dạng tiền tệ (VD: 150.000đ hoặc $15.00).
Lượt bán (VD: "Đã bán 1.2k").
Logic nâng cao: Áp dụng Pull to Refresh (Vuốt từ trên xuống để làm mới) và Infinite Scrolling (Cuộn xuống đáy tự động gọi API tải thêm trang tiếp theo - Pagination).
MÀN HÌNH 2: CHI TIẾT SẢN PHẨM (PRODUCT DETAIL SCREEN)
Hiệu ứng chuyển cảnh (Hero Animation): Khi bấm vào ảnh sản phẩm ở Trang chủ, ảnh phải phóng to mượt mà sang trang Chi tiết.
Giao diện Trình bày:
Slider Ảnh: Xem được nhiều góc độ của 1 sản phẩm (vuốt ngang).
Khối Giá & Tên: Tên sản phẩm in đậm, Giá đang bán (màu đỏ, to), Giá gốc (màu xám, có nét gạch ngang gạch bỏ).
Khối Phân loại (Variations): Hiển thị mục "Chọn Kích cỡ, Màu sắc". Nút có biểu tượng mũi tên điều hướng.
Mô tả chi tiết: Sử dụng RichText hoặc đoạn văn bản dài, hỗ trợ tính năng "Xem thêm/Thu gọn" nếu văn bản quá 5 dòng.
Bottom Navigation Bar (Cố định dưới đáy):
Chia làm 2 nửa: Một nửa chứa Icon Chat / Icon Giỏ hàng. Một nửa chứa 2 nút hành động chính: "Thêm vào giỏ hàng" và "Mua ngay".
Logic BottomSheet (Trọng tâm UI):
Khi bấm "Thêm vào giỏ" hoặc khối "Phân loại", không chuyển trang mà màn hình hiện tại tối lại, đẩy lên một BottomSheet từ dưới đáy.
Tại BottomSheet: Người dùng chọn Size (S, M, L), Màu sắc (Xanh, Đỏ), và Bấm nút Cộng/Trừ (+/-) để chọn số lượng.
Bấm "Xác nhận": Đóng BottomSheet, hiện một SnackBar thông báo "Thêm thành công", và con số Badge trên Giỏ hàng nảy số ngay lập tức.
MÀN HÌNH 3: GIỎ HÀNG (CART SCREEN) - Trọng tâm State Management
Cấu trúc UI Danh sách:
Sản phẩm trong giỏ phải được hiển thị dạng ListView.
Hệ thống Checkbox (Bắt buộc): Mỗi sản phẩm có 1 hộp kiểm (Checkbox). Dưới cùng màn hình (Sticky Bottom Bar) có một Checkbox "Chọn tất cả".
Mỗi Item hiển thị: Ảnh thu nhỏ, Tên, Phân loại (Size/Màu), Đơn giá, và Bộ đếm số lượng (+/-).
Hỗ trợ thao tác Vuốt sang trái để Xóa (Dismissible), hiện nền đỏ và icon thùng rác.
Logic Toán học & Liên kết Trạng thái (Phân loại sinh viên Giỏi):
Tính tiền động: Thanh "Tổng thanh toán" ở đáy màn hình CHỈ cộng dồn (Đơn giá x Số lượng) của những sản phẩm đang được check checkbox. Bỏ tick là tiền tự động trừ đi.
Logic Chọn Tất Cả: * Bấm "Chọn tất cả" -> Toàn bộ sản phẩm trong giỏ sáng dấu tick.
Chỉ cần bỏ tick 1 sản phẩm bất kỳ -> Dấu tick "Chọn tất cả" lập tức bị tắt.
Tự tay tick thủ công đủ 100% sản phẩm -> Dấu tick "Chọn tất cả" tự động sáng lên.
Logic Tăng/Giảm: Khi bấm (+/-) của một sản phẩm đang được tick, Tổng tiền phải nhảy số realtime mà không cần load lại trang. Trừ số lượng về 0 thì tự động hỏi "Bạn có muốn xóa không?".
MÀN HÌNH 4: THANH TOÁN & ĐƠN MUA (CHECKOUT & ORDERS)
Thanh toán (Checkout): * Truyền bộ list các sản phẩm đã được tick từ Giỏ hàng sang trang này.
UI giả lập: Điền địa chỉ nhận hàng, Chọn phương thức thanh toán (COD, Momo).
Bấm "Đặt Hàng": Bật Dialog báo thành công -> Xóa các sản phẩm đó khỏi Giỏ hàng -> Đẩy người dùng về Màn hình Trang chủ.
Đơn mua (Order History):
Sử dụng DefaultTab Controller để tạo thanh Tab bar vuốt ngang (Chờ xác nhận, Đang giao, Đã giao, Đã hủy).
Hiển thị danh sách các đơn hàng đã đặt thành công (lưu tạm vào danh sách Local hoặc đẩy lên Firebase).
 3. YÊU CẦU KỸ THUẬT & TỔ CHỨC SOURCE CODE
Kiến trúc Thư mục: Code phải chia rõ theo mô hình chuẩn (MVC hoặc MVVM). Tối thiểu phải có các folder: models/, screens/, widgets/ (chứa các nút bấm, thẻ item dùng chung), services/ (gọi API/Firebase), providers/ (hoặc controllers/ nếu dùng State Management).
State Management (Bắt buộc): Chức năng Giỏ hàng bắt buộc phải dùng Provider, GetX, hoặc thư viện tương đương để quản lý State. Tuyệt đối không dùng Navigator.push để truyền cả List Giỏ hàng qua lại giữa các trang (sẽ bị trừ điểm nặng).
Data Persistence (Điểm cộng): Giỏ hàng nên được lưu Offline bằng SharedPreferences hoặc lưu lên Firebase. Nếu người dùng tắt app bật lại, giỏ hàng vẫn phải còn nguyên dữ liệu hoặc xử lý ngoại lệ.
 


