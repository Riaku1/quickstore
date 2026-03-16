export const useSupplierOrders = () => {
  const supabase = useSupabaseClient();
  const user = useSupabaseUser();

  const fetchOrders = async () => {
    const { data, error } = await supabase
      .from('orders')
      .select('*, order_items(*, products(name))')
      .eq('supplier_id', user.value?.id)
      .order('created_at', { ascending: false });
    
    return { data, error };
  };

  return { fetchOrders };
}