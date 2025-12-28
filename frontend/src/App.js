import { useState, useEffect } from 'react';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3000';

function App() {
  const [items, setItems] = useState([]);
  const [formData, setFormData] = useState({ name: '', description: '' });
  const [editingId, setEditingId] = useState(null);
  const [loading, setLoading] = useState(false);

  // Fetch all items
  const fetchItems = async () => {
    try {
      setLoading(true);
      const res = await fetch(`${API_URL}/api/items`);
      const data = await res.json();
      setItems(data);
    } catch (error) {
      console.error('Error fetching items:', error);
      alert('Error fetching items');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchItems();
  }, []);

  // Create or Update item
  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      if (editingId) {
        await fetch(`${API_URL}/api/items/${editingId}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(formData)
        });
      } else {
        await fetch(`${API_URL}/api/items`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(formData)
        });
      }
      setFormData({ name: '', description: '' });
      setEditingId(null);
      fetchItems();
    } catch (error) {
      console.error('Error saving item:', error);
      alert('Error saving item');
    } finally {
      setLoading(false);
    }
  };

  // Delete item
  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this item?')) {
      return;
    }
    try {
      setLoading(true);
      await fetch(`${API_URL}/api/items/${id}`, { method: 'DELETE' });
      fetchItems();
    } catch (error) {
      console.error('Error deleting item:', error);
      alert('Error deleting item');
    } finally {
      setLoading(false);
    }
  };

  // Edit item
  const handleEdit = (item) => {
    setFormData({ name: item.name, description: item.description });
    setEditingId(item._id);
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>📝 CRUD Application</h1>
        <p>MERN Stack with MongoDB Atlas</p>
      </header>

      <div className="container">
        <div className="form-section">
          <h2>{editingId ? '✏️ Edit Item' : '➕ Add New Item'}</h2>
          <form onSubmit={handleSubmit}>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({...formData, name: e.target.value})}
              placeholder="Item Name"
              required
            />
            <input
              type="text"
              value={formData.description}
              onChange={(e) => setFormData({...formData, description: e.target.value})}
              placeholder="Description"
              required
            />
            <button type="submit" disabled={loading}>
              {loading ? '⏳ Processing...' : editingId ? '💾 Update' : '➕ Create'}
            </button>
            {editingId && (
              <button type="button" onClick={() => {
                setFormData({ name: '', description: '' });
                setEditingId(null);
              }}>
                ❌ Cancel
              </button>
            )}
          </form>
        </div>

        <div className="items-section">
          <h2>📋 Items List ({items.length})</h2>
          {loading && items.length === 0 ? (
            <p>Loading...</p>
          ) : items.length === 0 ? (
            <p className="empty">No items yet. Add your first item!</p>
          ) : (
            <div className="items-grid">
              {items.map(item => (
                <div key={item._id} className="item-card">
                  <h3>{item.name}</h3>
                  <p>{item.description}</p>
                  <div className="item-actions">
                    <button onClick={() => handleEdit(item)}>✏️ Edit</button>
                    <button onClick={() => handleDelete(item._id)} className="delete-btn">
                      🗑️ Delete
                    </button>
                  </div>
                  <small>Created: {new Date(item.createdAt).toLocaleString()}</small>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;

