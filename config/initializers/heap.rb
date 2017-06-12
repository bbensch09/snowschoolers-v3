if Rails.env.production?
  Heap.app_id = '429358529'
else
  Heap.app_id = '654668111'
end