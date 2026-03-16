-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Products Table (Inventory Management)
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  supplier_id UUID REFERENCES auth.users(id) NOT NULL,
  name TEXT NOT NULL,
  price_ugx INTEGER NOT NULL,
  unit TEXT DEFAULT 'item', -- e.g., '1kg', 'Heap', 'Bunch'
  in_stock BOOLEAN DEFAULT true,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Orders Table (Transactional Logic)
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  supplier_id UUID REFERENCES auth.users(id) NOT NULL,
  customer_id UUID NOT NULL, -- References customer profile
  status TEXT DEFAULT 'Received' CHECK (status IN ('Received', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled')),
  item_total_ugx INTEGER NOT NULL,
  delivery_fee_ugx INTEGER DEFAULT 4000, -- Standard local rate
  total_payout_ugx INTEGER GENERATED ALWAYS AS (item_total_ugx + delivery_fee_ugx) STORED,
  delivery_address TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Order Items (Junction Table for many-to-many)
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  quantity INTEGER NOT NULL DEFAULT 1,
  price_at_purchase INTEGER NOT NULL
);

-- 5. Row Level Security (RLS)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Policy: Suppliers can only see and edit their own products
CREATE POLICY "Suppliers can manage their own products" 
ON products FOR ALL 
USING (auth.uid() = supplier_id);

-- Policy: Suppliers can only see orders assigned to them
CREATE POLICY "Suppliers can view their assigned orders" 
ON orders FOR SELECT 
USING (auth.uid() = supplier_id);

-- Policy: Suppliers can update order status for their orders
CREATE POLICY "Suppliers can update their order status" 
ON orders FOR UPDATE 
USING (auth.uid() = supplier_id)
WITH CHECK (status IN ('Preparing', 'Out for Delivery'));