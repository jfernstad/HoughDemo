/*
 * ArrayList.c
 * by James Lawton
 *
 * The contents of this file are hereby released into the public domain,
 * to be used for any application, without restriction. No warranty is
 * provided. Use at your own risk.
 */

#include <stdlib.h> /* malloc free */
#include "ArrayList.h"

/* ArrayListNode is a chunk of memory, within a linked list
 * of such chunks.
 */
typedef struct _ArrayListNode {
	char * store;
	struct _ArrayListNode * next;
} ArrayListNode;

ArrayListNode * ArrayListNodeCreate(size_t cap);
void ArrayListNodeDestroy(ArrayListNode * node);

/* ArrayList is an implementation of a dynamically scalable array
 * of homogenous objects.
 */
struct _ArrayList {
	ArrayListNode * first;
	ArrayListNode * last;
	void * lastElem; /* Optimization for last element access. */
	size_t elemSize, elemsPerNode;
	size_t allocated; /* Number of elements currently allocated from the last node. */
	size_t elemCount; /* Total number of elements allocated in the array. */
    int retainCount; /* Owners */
};

/* ArrayListIter provides fast sequential access into the array.
 */
struct _ArrayListIter {
	ArrayList * lst;
	ArrayListNode * curr;
	size_t elemSize, elemsPerNode;
	size_t nextElem;
};


ArrayList * ArrayListCreate(size_t elemSize, size_t elemsPerNode)
{
	ArrayList * lst = (ArrayList *)malloc(sizeof(ArrayList));
	if (lst) {
		lst->first = lst->last = NULL;
		lst->lastElem = NULL;
		lst->elemSize = elemSize;
		lst->elemsPerNode = elemsPerNode;
		lst->allocated = lst->elemCount = 0;
        lst->retainCount = 1;
	}
	return lst;
}

void ArrayListRetain(ArrayList* lst){
	if (lst) {
        lst->retainCount++;
    }
}
void ArrayListDestroy(ArrayList * lst)
{
	if (lst) {
        lst->retainCount--;
        if (lst->retainCount <= 0) {
            if (lst->first) ArrayListNodeDestroy(lst->first);
            free(lst);
        }
	}
}

void ArrayListEmpty(ArrayList * lst)
{
	if (lst) {
		lst->last = lst->first;
		lst->elemCount = 0;
		lst->allocated = 0;
	}
}


void * ArrayListAllocElement(ArrayList * lst)
{
	if (lst) {
		if (!lst->last || lst->allocated >= lst->elemsPerNode) {
			if (lst->last && lst->last->next) {
				lst->last = lst->last->next;
			} else {
				ArrayListNode * node = ArrayListNodeCreate(lst->elemsPerNode * lst->elemSize);
				if (lst->last) {
					lst->last->next = node;
				} else {
					lst->first = node;
				}
				lst->last = node;
			}
			lst->allocated = 0;
		}
		++lst->elemCount;
		lst->lastElem = lst->last->store + (lst->elemSize * lst->allocated++);
		return lst->lastElem;
	}
	return NULL;
}

size_t ArrayListElementCount(ArrayList * lst)
{
	return lst->elemCount;
}

void * ArrayListElementAtIndex(ArrayList * lst, size_t index)
{
	/* assert(index < lst->elemCount); */
	if (index >= lst->elemCount) {
		return NULL;
	}
	
	ArrayListNode * node = lst->first;
	while (node && index >= lst->elemsPerNode) {
		node = node->next;
		index -= lst->elemsPerNode;
	}
	
	if (node) {
		return node->store + (lst->elemSize * index);
	}
	
	return NULL; /* Internal error */
}

void * ArrayListLastElement(ArrayList * lst)
{
	return lst ? lst->lastElem : NULL;
	
#if 0
	/* Optimize the general case. */
	if (lst && lst->last && lst->allocated) {
		return lst->last->store + (lst->elemSize * (lst->allocated - 1));
	}
	return ArrayListElementAtIndex(lst, lst->elemCount - 1);
#endif
}


ArrayListNode * ArrayListNodeCreate(size_t cap)
{
	ArrayListNode * node = (ArrayListNode *)malloc(sizeof(ArrayListNode));
	if (node) {
		node->store = (char *)malloc(cap);
		node->next = NULL;
		if (!node->store) {
			free(node); node = NULL;
		}
	}
	return node;
}

void ArrayListNodeDestroy(ArrayListNode * node)
{
	while (node) {
		ArrayListNode * next = node->next;
		if (node->store) free(node->store);
		node = next;
	}
}


ArrayListIter * ArrayListIterCreate(ArrayList * lst)
{
	ArrayListIter * iter = NULL;
	if (lst) {
		iter = (ArrayListIter *)malloc(sizeof(ArrayListIter));
		if (iter) {
			iter->lst = lst;
			iter->curr = lst->first;
			iter->elemSize = lst->elemSize;
			iter->elemsPerNode = lst->elemsPerNode;
			iter->nextElem = 0;
		}
	}
	return iter;
}

void ArrayListIterDestroy(ArrayListIter * iter)
{
	if (iter) free(iter);
}

void ArrayListIterReset(ArrayListIter * iter)
{
	if (iter) {
		iter->curr = iter->lst->first;
		iter->nextElem = 0;
	}
}

void * ArrayListIterStep(ArrayListIter * iter)
{
	void * elem = NULL;
	if (iter && iter->curr) {
		if (iter->curr == iter->lst->last && iter->nextElem >= iter->lst->allocated) {
			return NULL;
		}
		if (iter->nextElem >= iter->elemsPerNode) {
			ArrayListNode * next = iter->curr->next;
			iter->curr = next;
			iter->nextElem = 0;
		}
		if (iter->curr) {
			elem = iter->curr->store + (iter->elemSize * iter->nextElem++);
		}
	}
	return elem;
}
